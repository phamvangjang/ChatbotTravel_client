import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/attraction_model.dart';
import '../models/itinerary_item.dart';
import '../views/widgets/save_itinerary_dialog.dart';



class HCMCMapTestPage extends StatelessWidget {
  const HCMCMapTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đã load dotenv chưa
    final mapboxToken = dotenv.env["MAPBOX_ACCESS_TOKEN"];

    // Tạo dữ liệu mẫu
    final sampleItinerary = _createHCMCSampleItinerary();
    final selectedDate = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất PDF với bản đồ Hồ Chí Minh'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lịch trình Hồ Chí Minh: ${sampleItinerary.length} địa điểm',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            if (mapboxToken != null && mapboxToken.isNotEmpty)
              Text(
                'Sử dụng Mapbox để tạo bản đồ',
                style: TextStyle(fontSize: 14, color: Colors.green),
              )
            else
              Text(
                'Sử dụng OpenStreetMap để tạo bản đồ',
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                SaveItineraryDialog.show(
                  context,
                  itinerary: sampleItinerary,
                  selectedDate: selectedDate,
                  onSave: () async {
                    // Giả lập lưu vào database
                    await Future.delayed(const Duration(seconds: 1));
                    return true;
                  },
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Xuất PDF với bản đồ Hồ Chí Minh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ItineraryItem> _createHCMCSampleItinerary() {
    // Tạo danh sách các địa điểm mẫu ở Hồ Chí Minh
    final attractions = [
      Attraction(
        id: '1',
        name: 'Nhà thờ Đức Bà',
        address: 'Công xã Paris, Bến Nghé, Quận 1, Hồ Chí Minh',
        description: 'Nhà thờ chính tòa của Tổng giáo phận Thành phố Hồ Chí Minh',
        imageUrl: 'https://example.com/notre-dame.jpg',
        location: LatLng(10.7798, 106.6990),
        rating: 4.7,
        price: 0,
        category: 'Religious',
      ),
      Attraction(
        id: '2',
        name: 'Bưu điện Trung tâm Sài Gòn',
        address: '2 Công xã Paris, Bến Nghé, Quận 1, Hồ Chí Minh',
        description: 'Công trình kiến trúc cổ điển Pháp nổi tiếng',
        imageUrl: 'https://example.com/central-post-office.jpg',
        location: LatLng(10.7801, 106.7001),
        rating: 4.6,
        price: 0,
        category: 'Historical',
      ),
      Attraction(
        id: '3',
        name: 'Chợ Bến Thành',
        address: 'Lê Lợi, Bến Thành, Quận 1, Hồ Chí Minh',
        description: 'Khu chợ nổi tiếng với nhiều mặt hàng đa dạng',
        imageUrl: 'https://example.com/ben-thanh-market.jpg',
        location: LatLng(10.7721, 106.6980),
        rating: 4.3,
        price: 0,
        category: 'Shopping',
      ),
      Attraction(
        id: '4',
        name: 'Bảo tàng Chứng tích Chiến tranh',
        address: '28 Võ Văn Tần, Phường 6, Quận 3, Hồ Chí Minh',
        description: 'Bảo tàng về lịch sử chiến tranh Việt Nam',
        imageUrl: 'https://example.com/war-remnants-museum.jpg',
        location: LatLng(10.7795, 106.6924),
        rating: 4.5,
        price: 40000,
        category: 'Museum',
      ),
      Attraction(
        id: '5',
        name: 'Dinh Độc Lập',
        address: '135 Nam Kỳ Khởi Nghĩa, Bến Thành, Quận 1, Hồ Chí Minh',
        description: 'Công trình kiến trúc lịch sử quan trọng',
        imageUrl: 'https://example.com/independence-palace.jpg',
        location: LatLng(10.7769, 106.6953),
        rating: 4.4,
        price: 40000,
        category: 'Historical',
      ),
      Attraction(
        id: '6',
        name: 'Phố đi bộ Nguyễn Huệ',
        address: 'Nguyễn Huệ, Bến Nghé, Quận 1, Hồ Chí Minh',
        description: 'Khu phố đi bộ sầm uất với nhiều hoạt động giải trí',
        imageUrl: 'https://example.com/nguyen-hue-walking-street.jpg',
        location: LatLng(10.7731, 106.7029),
        rating: 4.6,
        price: 0,
        category: 'Entertainment',
      ),
      Attraction(
        id: '7',
        name: 'Chùa Ngọc Hoàng',
        address: '73 Mai Thị Lựu, Đa Kao, Quận 1, Hồ Chí Minh',
        description: 'Ngôi chùa cổ với kiến trúc độc đáo',
        imageUrl: 'https://example.com/jade-emperor-pagoda.jpg',
        location: LatLng(10.7868, 106.7010),
        rating: 4.5,
        price: 0,
        category: 'Religious',
      ),
    ];

    // Tạo lịch trình với thời gian
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9, 0); // Bắt đầu lúc 9:00

    final itinerary = <ItineraryItem>[];

    // Nhà thờ Đức Bà - 9:00 - 45 phút
    itinerary.add(ItineraryItem(
      attraction: attractions[0],
      visitTime: today,
      estimatedDuration: const Duration(minutes: 45),
      notes: 'Chụp ảnh bên ngoài nhà thờ',
    ));

    // Bưu điện Trung tâm - 10:00 - 30 phút
    itinerary.add(ItineraryItem(
      attraction: attractions[1],
      visitTime: today.add(const Duration(hours: 1)),
      estimatedDuration: const Duration(minutes: 30),
      notes: 'Mua bưu thiếp lưu niệm',
    ));

    // Chợ Bến Thành - 11:00 - 1h30p
    itinerary.add(ItineraryItem(
      attraction: attractions[2],
      visitTime: today.add(const Duration(hours: 2)),
      estimatedDuration: const Duration(hours: 1, minutes: 30),
      notes: 'Mua đồ lưu niệm và ăn trưa tại chợ',
    ));

    // Bảo tàng Chứng tích Chiến tranh - 14:00 - 1h30p
    itinerary.add(ItineraryItem(
      attraction: attractions[3],
      visitTime: today.add(const Duration(hours: 5)),
      estimatedDuration: const Duration(hours: 1, minutes: 30),
      notes: 'Tham quan các phòng trưng bày chính',
    ));

    // Dinh Độc Lập - 16:00 - 1h
    itinerary.add(ItineraryItem(
      attraction: attractions[4],
      visitTime: today.add(const Duration(hours: 7)),
      estimatedDuration: const Duration(hours: 1),
      notes: '',
    ));

    // Phố đi bộ Nguyễn Huệ - 18:00 - 1h
    itinerary.add(ItineraryItem(
      attraction: attractions[5],
      visitTime: today.add(const Duration(hours: 9)),
      estimatedDuration: const Duration(hours: 1),
      notes: 'Ngắm hoàng hôn và chụp ảnh',
    ));

    // Chùa Ngọc Hoàng - 19:30 - 45p
    itinerary.add(ItineraryItem(
      attraction: attractions[6],
      visitTime: today.add(const Duration(hours: 10, minutes: 30)),
      estimatedDuration: const Duration(minutes: 45),
      notes: 'Tham quan buổi tối',
    ));

    return itinerary;
  }
}

