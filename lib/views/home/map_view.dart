import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/tourist_attraction_model.dart';
import '../../viewmodels/home/map_viewmodel.dart';

class MapView extends StatelessWidget {
  final String messageContent;
  final int conversationId;

  const MapView({
    Key? key,
    required this.messageContent,
    required this.conversationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: _MapViewContent(
        messageContent: messageContent,
        conversationId: conversationId,
      ),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  final String messageContent;
  final int conversationId;

  const _MapViewContent({
    required this.messageContent,
    required this.conversationId,
  });

  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo ViewModel với dữ liệu từ tin nhắn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MapViewModel>(context, listen: false);
      viewModel.initialize(widget.messageContent, widget.conversationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bản đồ du lịch'),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng chia sẻ đang được phát triển'),
                    ),
                  );
                },
              ),
            ],
          ),
          body:
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      // Thông tin tin nhắn
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin từ AI:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.messageContent,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      // Danh sách địa điểm được phát hiện
                      if (viewModel.detectedAttractions.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.green.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Địa điểm được phát hiện:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children:
                                    viewModel.detectedAttractions.map((
                                      attraction,
                                    ) {
                                      final isSelected =
                                          viewModel.selectedAttraction?.id ==
                                          attraction.id;
                                      return GestureDetector(
                                        onTap:
                                            () => viewModel.selectAttraction(
                                              attraction,
                                            ),
                                        child: Chip(
                                          label: Text(
                                            attraction.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                          ),
                                          backgroundColor:
                                              isSelected
                                                  ? Colors.green.shade600
                                                  : Colors.green.shade100,
                                          side: BorderSide(
                                            color:
                                                isSelected
                                                    ? Colors.green.shade700
                                                    : Colors.green.shade300,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),

                      // Hiển thị thông tin địa điểm được chọn
                      if (viewModel.selectedAttraction != null)
                        Expanded(
                          child: _AttractionDetailView(
                            attraction: viewModel.selectedAttraction!,
                            onAddToItinerary: () {
                              viewModel.addToItinerary(
                                viewModel.selectedAttraction!,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã thêm ${viewModel.selectedAttraction!.name} vào lịch trình',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),

                      // Placeholder khi không có địa điểm được chọn
                      if (viewModel.selectedAttraction == null)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  viewModel.detectedAttractions.isEmpty
                                      ? 'Không tìm thấy địa điểm du lịch trong tin nhắn'
                                      : 'Chọn một địa điểm để xem chi tiết',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Mở dialog tìm kiếm địa điểm
                                    _showSearchDialog(context, viewModel);
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Tìm địa điểm'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Hiển thị lịch trình
                      if (viewModel.itinerary.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.blue.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Lịch trình của bạn:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${viewModel.itinerary.length} địa điểm',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: viewModel.itinerary.length,
                                  itemBuilder: (context, index) {
                                    final attraction =
                                        viewModel.itinerary[index];
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Chip(
                                        label: Text(
                                          '${index + 1}. ${attraction.name}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.blue.shade100,
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted:
                                            () => viewModel.removeFromItinerary(
                                              attraction,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Action buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Quay lại chat'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    viewModel.itinerary.isEmpty
                                        ? null
                                        : () async {
                                          final success =
                                              await viewModel.saveItinerary();
                                          if (success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Lịch trình đã được lưu',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                icon: const Icon(Icons.save),
                                label: const Text('Lưu lịch trình'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  // Dialog tìm kiếm địa điểm
  void _showSearchDialog(BuildContext context, MapViewModel viewModel) {
    final searchController = TextEditingController();
    List<TouristAttraction> searchResults = [];

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Tìm địa điểm du lịch'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tên địa điểm...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          if (value.length >= 2) {
                            setState(() {
                              searchResults =
                                  viewModel.allAttractions
                                      .where(
                                        (a) => a.name.toLowerCase().contains(
                                          value.toLowerCase(),
                                        ),
                                      )
                                      .toList();
                            });
                          } else {
                            setState(() {
                              searchResults = [];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            searchResults.isEmpty
                                ? Center(
                                  child: Text(
                                    searchController.text.isEmpty
                                        ? 'Nhập tên địa điểm để tìm kiếm'
                                        : 'Không tìm thấy kết quả',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final attraction = searchResults[index];
                                    return ListTile(
                                      title: Text(attraction.name),
                                      subtitle: Text(
                                        attraction.address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(
                                          attraction.name.substring(0, 1),
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        viewModel.selectAttraction(attraction);
                                        Navigator.pop(dialogContext);
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          ),
    );
  }
}

// Widget hiển thị chi tiết địa điểm
class _AttractionDetailView extends StatelessWidget {
  final TouristAttraction attraction;
  final VoidCallback onAddToItinerary;

  const _AttractionDetailView({
    required this.attraction,
    required this.onAddToItinerary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh địa điểm
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(attraction.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),

          // Thông tin địa điểm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên địa điểm
                Text(
                  attraction.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  attraction.englishName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),

                // Địa chỉ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        attraction.address,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Đánh giá
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade400, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${attraction.rating}/5.0',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(attraction.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryName(attraction.category),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mô tả
                const Text(
                  'Mô tả:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  attraction.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Thông tin thêm
                const Text(
                  'Thông tin thêm:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _buildAdditionalInfo(
                  'Giờ mở cửa',
                  attraction.additionalInfo['openingHours'] ??
                      'Không có thông tin',
                ),
                _buildAdditionalInfo(
                  'Thời điểm lý tưởng',
                  attraction.additionalInfo['bestTimeToVisit'] ??
                      'Không có thông tin',
                ),
                _buildAdditionalInfo(
                  'Giá vé',
                  attraction.additionalInfo['entranceFee'] ??
                      'Không có thông tin',
                ),
                if (attraction.additionalInfo.containsKey('note'))
                  _buildAdditionalInfo(
                    'Lưu ý',
                    attraction.additionalInfo['note'],
                  ),
                const SizedBox(height: 16),

                // Nút thêm vào lịch trình
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddToItinerary,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Thêm vào lịch trình'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin bổ sung
  Widget _buildAdditionalInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // Lấy màu cho danh mục
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'historical':
        return Colors.brown.shade600;
      case 'cultural':
        return Colors.purple.shade600;
      case 'religious':
        return Colors.indigo.shade600;
      case 'modern':
        return Colors.blue.shade600;
      case 'shopping':
        return Colors.orange.shade600;
      case 'entertainment':
        return Colors.pink.shade600;
      case 'museum':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // Lấy tên danh mục
  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'historical':
        return 'Di tích lịch sử';
      case 'cultural':
        return 'Văn hóa';
      case 'religious':
        return 'Tôn giáo';
      case 'modern':
        return 'Hiện đại';
      case 'shopping':
        return 'Mua sắm';
      case 'entertainment':
        return 'Giải trí';
      case 'museum':
        return 'Bảo tàng';
      default:
        return category;
    }
  }
}
