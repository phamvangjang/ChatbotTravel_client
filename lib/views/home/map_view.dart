import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapView extends StatefulWidget {
  final String messageContent;
  final int conversationId;

  const MapView({
    Key? key,
    required this.messageContent,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>{
  List<String> _extractedLocations = [];

  @override
  void initState() {
    super.initState();
    _extractLocationsFromMessage();
  }

  void _extractLocationsFromMessage() {
    // Đơn giản hóa việc extract địa điểm từ tin nhắn
    // Trong thực tế, bạn có thể sử dụng NLP hoặc regex phức tạp hơn
    final locations = <String>[];
    final content = widget.messageContent.toLowerCase();

    // Danh sách một số địa điểm phổ biến ở HCM
    final popularLocations = [
      'bến thành', 'chợ bến thành',
      'nhà thờ đức bà', 'cathedral',
      'dinh độc lập', 'reunification palace',
      'bưu điện trung tâm', 'central post office',
      'phố đi bộ nguyễn huệ', 'nguyen hue walking street',
      'bitexco', 'skydeck',
      'landmark 81',
      'chợ lớn', 'cholon',
      'jade emperor pagoda', 'chùa ngọc hoàng',
      'war remnants museum', 'bảo tàng chứng tích chiến tranh',
      'cu chi tunnels', 'địa đạo củ chi',
      'mekong delta', 'đồng bằng sông cửu long',
    ];

    for (final location in popularLocations) {
      if (content.contains(location)) {
        locations.add(location);
      }
    }

    setState(() {
      _extractedLocations = locations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ du lịch'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share map
            },
          ),
        ],
      ),
      body: Column(
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
                  widget.messageContent,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Danh sách địa điểm được phát hiện
          if (_extractedLocations.isNotEmpty)
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
                    children: _extractedLocations.map((location) {
                      return Chip(
                        label: Text(
                          location,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.green.shade100,
                        side: BorderSide(color: Colors.green.shade300),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Placeholder cho bản đồ
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
                    'Bản đồ sẽ hiển thị ở đây',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tích hợp Google Maps hoặc OpenStreetMap',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement map integration
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng bản đồ đang được phát triển'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_location),
                    label: const Text('Thêm địa điểm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
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
                    onPressed: () {
                      // Implement save itinerary
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lịch trình đã được lưu'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu lịch trình'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


