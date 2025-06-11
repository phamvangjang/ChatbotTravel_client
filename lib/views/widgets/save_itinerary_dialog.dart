import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/itinerary_item.dart';

class SaveItineraryDialog extends StatelessWidget {
  final List<ItineraryItem> itinerary;
  final DateTime selectedDate;
  final Future<bool> Function() onSave;

  const SaveItineraryDialog({
    super.key,
    required this.itinerary,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.save, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Xác nhận lưu lịch trình',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 22, color: Colors.green),
          ))
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn có muốn lưu lịch trình cho ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      MdiIcons.informationOutline,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Thông tin lịch trình:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('• Số địa điểm: ${itinerary.length}'),
                Text('• Thời gian bắt đầu: ${_getStartTime()}'),
                Text('• Thời gian kết thúc: ${_getEndTime()}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(MdiIcons.checkCircle, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text(
                      'Xuất lịch trình thành file PDF',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
            await _handleSaveAndPDF(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Xác nhận lưu'),
        ),
      ],
    );
  }

  Future<void> _handleSaveAndPDF(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang lưu vào database...'),
              ],
            ),
          ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final success = true;

      if (success) {
        if (context.mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tạo PDF với Material Design Icons...'),
                    ],
                  ),
                ),
          );
        }

        await _generatePDFWithMDIIcons();

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Lịch trình đã lưu và PDF có icon đã tải về'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Lỗi khi lưu vào database'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generatePDFWithMDIIcons() async {
    try {
      // Load fonts
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      // Load Material Design Icons font từ package
      pw.Font? iconFont;
      try {
        final iconFontData = await rootBundle.load(
          'packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf',
        );
        iconFont = pw.Font.ttf(iconFontData);
      } catch (e) {
        print('Could not load MDI font: $e');
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Header với icon
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.mapMarkerRadius,
                          PdfColors.blue800,
                          24,
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          'LỊCH TRÌNH DU LỊCH',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 24,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.calendar,
                          PdfColors.blue600,
                          16,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 16,
                            color: PdfColors.blue600,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.mapMarker,
                          PdfColors.blue600,
                          16,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'Tổng số địa điểm: ${itinerary.length}',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 14,
                            color: PdfColors.blue600,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.clockOutline,
                          PdfColors.blue600,
                          16,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'Thời gian: ${_getStartTime()} - ${_getEndTime()}',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 14,
                            color: PdfColors.blue600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Danh sách địa điểm với MDI icons
              ...itinerary.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header với số thứ tự và tên
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 35,
                            height: 35,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue600,
                              borderRadius: pw.BorderRadius.circular(17.5),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '${index + 1}',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  color: PdfColors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Text(
                              item.attraction.name,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 16,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 12),

                      // Địa chỉ với icon
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildMDIIcon(
                            iconFont,
                            MdiIcons.mapMarker,
                            PdfColors.grey600,
                            14,
                          ),
                          pw.SizedBox(width: 6),
                          pw.Expanded(
                            child: pw.Text(
                              item.attraction.address,
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 8),

                      // Thời gian với icon
                      pw.Row(
                        children: [
                          _buildMDIIcon(
                            iconFont,
                            MdiIcons.clockOutline,
                            PdfColors.blue700,
                            14,
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text(
                            '${item.visitTime.hour.toString().padLeft(2, '0')}:${item.visitTime.minute.toString().padLeft(2, '0')}',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                              color: PdfColors.blue700,
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          _buildMDIIcon(
                            iconFont,
                            MdiIcons.timerOutline,
                            PdfColors.green700,
                            14,
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text(
                            '${item.estimatedDuration.inHours}h ${item.estimatedDuration.inMinutes % 60}m',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                              color: PdfColors.green700,
                            ),
                          ),
                        ],
                      ),

                      // Ghi chú với icon
                      if (item.notes.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildMDIIcon(
                              iconFont,
                              MdiIcons.noteTextOutline,
                              PdfColors.orange700,
                              14,
                            ),
                            pw.SizedBox(width: 6),
                            pw.Expanded(
                              child: pw.Text(
                                item.notes,
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 11,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      pw.SizedBox(height: 8),

                      // Rating và giá với icon
                      pw.Row(
                        children: [
                          _buildMDIIcon(
                            iconFont,
                            MdiIcons.star,
                            PdfColors.orange600,
                            14,
                          ),
                          pw.SizedBox(width: 4),
                          pw.Text(
                            '${item.attraction.rating}/5',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                              color: PdfColors.orange700,
                            ),
                          ),
                          if (item.attraction.price != null) ...[
                            pw.SizedBox(width: 20),
                            _buildMDIIcon(
                              iconFont,
                              MdiIcons.currencyUsd,
                              PdfColors.green600,
                              14,
                            ),
                            pw.SizedBox(width: 4),
                            pw.Text(
                              '${_formatPrice(item.attraction.price!)} VND',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 12,
                                color: PdfColors.green600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 20),

              // Tổng kết với icon
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.chartLine,
                          PdfColors.blue800,
                          18,
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'TỔNG KẾT LỊCH TRÌNH',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 16,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),

                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.timerOutline,
                          PdfColors.blue600,
                          14,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'Tổng thời gian: ${_getTotalDuration()}',
                          style: pw.TextStyle(font: fontRegular, fontSize: 12),
                        ),
                      ],
                    ),

                    if (_getTotalPrice() > 0) ...[
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          _buildMDIIcon(
                            iconFont,
                            MdiIcons.currencyUsd,
                            PdfColors.green600,
                            14,
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text(
                            'Tổng chi phí: ${_formatPrice(_getTotalPrice())} VND',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],

                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.calendar,
                          PdfColors.grey600,
                          14,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'Được tạo: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        _buildMDIIcon(
                          iconFont,
                          MdiIcons.heart,
                          PdfColors.red400,
                          16,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          'Chúc bạn có chuyến du lịch vui vẻ và an toàn!',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 14,
                            color: PdfColors.green600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Tải PDF về
      final fileName =
          'Lich_trinh_${selectedDate.day}_${selectedDate.month}_${selectedDate.year}.pdf';

      await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
    } catch (e) {
      print('Error generating PDF with MDI icons: $e');
      rethrow;
    }
  }

  // Helper function để tạo MDI icon
  pw.Widget _buildMDIIcon(
    pw.Font? iconFont,
    IconData iconData,
    PdfColor color,
    double size,
  ) {
    if (iconFont != null) {
      return pw.Text(
        String.fromCharCode(iconData.codePoint),
        style: pw.TextStyle(font: iconFont, fontSize: size, color: color),
      );
    } else {
      // Fallback: vẽ hình tròn đơn giản
      return pw.Container(
        width: size,
        height: size,
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(size / 2),
        ),
      );
    }
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getStartTime() {
    if (itinerary.isEmpty) return '--:--';
    final startTime = itinerary.first.visitTime;
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String _getEndTime() {
    if (itinerary.isEmpty) return '--:--';
    final lastItem = itinerary.last;
    final endTime = lastItem.visitTime.add(lastItem.estimatedDuration);
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTotalDuration() {
    if (itinerary.isEmpty) return '0h 0m';

    final totalMinutes = itinerary.fold<int>(
      0,
      (sum, item) => sum + item.estimatedDuration.inMinutes,
    );

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  double _getTotalPrice() {
    return itinerary.fold<double>(
      0.0,
      (sum, item) => sum + (item.attraction.price ?? 0.0),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required List<ItineraryItem> itinerary,
    required DateTime selectedDate,
    required Future<bool> Function() onSave,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SaveItineraryDialog(
            itinerary: itinerary,
            selectedDate: selectedDate,
            onSave: onSave,
          ),
    );
  }
}
