import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:mobilev2/scape/attraction_scape.dart';

import '../../models/attraction_model.dart';

class AttractionService{
  static final AttractionService _instance = AttractionService._internal();
  final AttractionScape _attractionScape = AttractionScape();
  factory AttractionService() => _instance;
  AttractionService._internal();

  // URL API backend (thay đổi theo API thực tế của bạn)
  static const String baseUrl = 'https://your-api-domain.com/api';

  // Dữ liệu mẫu cho các địa điểm du lịch ở Hồ Chí Minh
  final List<Attraction> _sampleAttractions = [
    Attraction(
      id: '1',
      name: 'Nhà thờ Đức Bà',
      address: 'Công xã Paris, Bến Nghé, Quận 1, Hồ Chí Minh',
      description: 'Nhà thờ chính tòa Đức Bà Sài Gòn là nhà thờ chính tòa của Tổng giáo phận Thành phố Hồ Chí Minh.',
      imageUrl: 'https://cdn.projectexpedition.com/photos/57e5ff71a61d3_sized.jpg',
      rating: 4.5,
      location: LatLng(10.7798, 106.6990),
      category: 'religious',
      tags: ['nhà thờ', 'kiến trúc', 'lịch sử'],
      openingHours: '8:00 - 11:00, 15:00 - 16:00',
    ),
    Attraction(
      id: '2',
      name: 'Bưu điện Trung tâm Sài Gòn',
      address: '2 Công xã Paris, Bến Nghé, Quận 1, Hồ Chí Minh',
      description: 'Bưu điện Trung tâm Sài Gòn là một công trình kiến trúc tiêu biểu tại Thành phố Hồ Chí Minh.',
      imageUrl: 'https://vietnamtour.in/wp-content/uploads/Saigon-Central-Post-Office.jpg.jpg',
      rating: 4.3,
      location: LatLng(10.7802, 106.7001),
      category: 'historical',
      tags: ['bưu điện', 'kiến trúc', 'lịch sử'],
      openingHours: '7:00 - 19:00',
    ),
    Attraction(
      id: '3',
      name: 'Chợ Bến Thành',
      address: 'Lê Lợi, Bến Thành, Quận 1, Hồ Chí Minh',
      description: 'Chợ Bến Thành là một khu chợ nằm ở Quận 1, Thành phố Hồ Chí Minh và là một biểu tượng của thành phố này.',
      imageUrl: 'https://cdn3.ivivu.com/2022/10/cho_ben_thanh_ivivu.jpeg',
      rating: 4.0,
      // location: LatLng(10.7721, 106.6980),
      location: LatLng(10.772427,106.697988
      ),
      category: 'market',
      tags: ['chợ', 'mua sắm', 'ẩm thực'],
      openingHours: '6:00 - 18:00',
    ),
    Attraction(
      id: '4',
      name: 'Bảo tàng Chứng tích Chiến tranh',
      address: '28 Võ Văn Tần, Phường 6, Quận 3, Hồ Chí Minh',
      description: 'Bảo tàng Chứng tích Chiến tranh là một bảo tàng về Chiến tranh Việt Nam tại Thành phố Hồ Chí Minh.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/War_Remnants_Museum%2C_HCMC%2C_front.JPG/500px-War_Remnants_Museum%2C_HCMC%2C_front.JPG',
      rating: 4.6,
      location: LatLng(10.7798, 106.6922),
      category: 'museum',
      tags: ['bảo tàng', 'lịch sử', 'chiến tranh'],
      openingHours: '7:30 - 17:30',
      price: 40000,
    ),
    Attraction(
      id: '5',
      name: 'Dinh Độc Lập',
      address: '135 Nam Kỳ Khởi Nghĩa, Phường Bến Thành, Quận 1, Hồ Chí Minh',
      description: 'Dinh Độc Lập, còn được gọi là Dinh Thống Nhất, là một công trình kiến trúc lịch sử tại Thành phố Hồ Chí Minh.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/7/7d/20190923_Independence_Palace-10.jpg',
      rating: 4.4,
      location: LatLng(10.7772, 106.6958),
      category: 'historical',
      tags: ['dinh thự', 'lịch sử', 'kiến trúc'],
      openingHours: '8:00 - 11:00, 13:00 - 16:00',
      price: 65000,
    ),
    Attraction(
      id: '6',
      name: 'Phố đi bộ Nguyễn Huệ',
      address: 'Đường Nguyễn Huệ, Quận 1, Hồ Chí Minh',
      description: 'Phố đi bộ Nguyễn Huệ là một không gian văn hóa, giải trí và mua sắm tại trung tâm Thành phố Hồ Chí Minh.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Nguyen_Hue_Street_2020.jpg/1920px-Nguyen_Hue_Street_2020.jpg',
      rating: 4.2,
      location: LatLng(10.7743, 106.7038),
      category: 'entertainment',
      tags: ['phố đi bộ', 'giải trí', 'mua sắm'],
      openingHours: '24/7',
    ),
    Attraction(
      id: '7',
      name: 'Chùa Jade Emperor',
      address: '73 Mai Thị Lựu, Đa Kao, Quận 1, Hồ Chí Minh',
      description: 'Chùa Ngọc Hoàng là một ngôi chùa Đạo giáo nổi tiếng tại Thành phố Hồ Chí Minh.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Jade_Emperor_Pagoda_Saigon.jpg/800px-Jade_Emperor_Pagoda_Saigon.jpg',
      rating: 4.7,
      location: LatLng(10.7892, 106.6917),
      category: 'religious',
      tags: ['chùa', 'tâm linh', 'văn hóa'],
      openingHours: '6:00 - 18:00',
    ),
    Attraction(
      id: '8',
      name: 'Landmark 81',
      address: '720A Điện Biên Phủ, Bình Thạnh, Hồ Chí Minh',
      description: 'Landmark 81 là tòa nhà chọc trời cao nhất Việt Nam và Đông Nam Á.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e6/Ho_Chi_Minh_City_panorama_2019_%28cropped%29.jpg',
      rating: 4.3,
      location: LatLng(10.7953, 106.7218),
      category: 'modern',
      tags: ['tòa nhà', 'hiện đại', 'view đẹp'],
      openingHours: '9:00 - 22:00',
      price: 200000,
    ),
  ];

  /// Lấy danh sách địa điểm gần vị trí hiện tại
  Future<List<Attraction>> getNearbyAttractions(
      LatLng currentLocation, {
        double radiusInKm = 10.0,
        int limit = 20,
      }) async {
    try {
      // Trong thực tế, bạn sẽ gọi API
      // final response = await http.get(
      //   Uri.parse('$baseUrl/attractions/nearby?lat=${currentLocation.latitude}&lng=${currentLocation.longitude}&radius=$radiusInKm&limit=$limit'),
      // );

      // Hiện tại sử dụng dữ liệu mẫu
      await Future.delayed(const Duration(milliseconds: 500)); // Giả lập delay API

      // Lọc địa điểm trong bán kính
      List<Attraction> nearbyAttractions = _attractionScape.hcmAttractions.where((attraction) {
        double distance = _calculateDistance(currentLocation, attraction.location);
        return distance <= radiusInKm * 1000; // Chuyển km sang mét
      }).toList();

      // Sắp xếp theo khoảng cách
      nearbyAttractions.sort((a, b) {
        double distanceA = _calculateDistance(currentLocation, a.location);
        double distanceB = _calculateDistance(currentLocation, b.location);
        return distanceA.compareTo(distanceB);
      });

      return nearbyAttractions.take(limit).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách địa điểm: $e');
      return [];
    }
  }

  /// Tìm kiếm địa điểm theo từ khóa
  Future<List<Attraction>> searchAttractions(
      String query, {
        LatLng? currentLocation,
        int limit = 20,
      }) async {
    try {
      // Trong thực tế, bạn sẽ gọi API
      // final response = await http.get(
      //   Uri.parse('$baseUrl/attractions/search?q=$query&limit=$limit'),
      // );

      await Future.delayed(const Duration(milliseconds: 300));

      // Tìm kiếm trong dữ liệu mẫu
      String lowerQuery = query.toLowerCase();
      List<Attraction> results = _sampleAttractions.where((attraction) {
        return attraction.name.toLowerCase().contains(lowerQuery) ||
            attraction.address.toLowerCase().contains(lowerQuery) ||
            attraction.description.toLowerCase().contains(lowerQuery) ||
            attraction.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();

      // Sắp xếp theo khoảng cách nếu có vị trí hiện tại
      if (currentLocation != null) {
        results.sort((a, b) {
          double distanceA = _calculateDistance(currentLocation, a.location);
          double distanceB = _calculateDistance(currentLocation, b.location);
          return distanceA.compareTo(distanceB);
        });
      }

      return results.take(limit).toList();
    } catch (e) {
      print('Lỗi khi tìm kiếm địa điểm: $e');
      return [];
    }
  }

  /// Lấy thông tin chi tiết của một địa điểm
  Future<Attraction?> getAttractionById(String id) async {
    try {
      // Trong thực tế, bạn sẽ gọi API
      // final response = await http.get(
      //   Uri.parse('$baseUrl/attractions/$id'),
      // );

      await Future.delayed(const Duration(milliseconds: 200));

      return _sampleAttractions.firstWhere(
            (attraction) => attraction.id == id,
        orElse: () => throw Exception('Không tìm thấy địa điểm'),
      );
    } catch (e) {
      print('Lỗi khi lấy thông tin địa điểm: $e');
      return null;
    }
  }

  /// Lấy địa điểm theo danh mục
  Future<List<Attraction>> getAttractionsByCategory(
      String category, {
        LatLng? currentLocation,
        int limit = 20,
      }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      List<Attraction> results = _sampleAttractions
          .where((attraction) => attraction.category == category)
          .toList();

      if (currentLocation != null) {
        results.sort((a, b) {
          double distanceA = _calculateDistance(currentLocation, a.location);
          double distanceB = _calculateDistance(currentLocation, b.location);
          return distanceA.compareTo(distanceB);
        });
      }

      return results.take(limit).toList();
    } catch (e) {
      print('Lỗi khi lấy địa điểm theo danh mục: $e');
      return [];
    }
  }

  /// Lấy tất cả địa điểm
  Future<List<Attraction>> getAllAttractions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return List.from(_sampleAttractions);
    } catch (e) {
      print('Lỗi khi lấy tất cả địa điểm: $e');
      return [];
    }
  }

  /// Phát hiện địa điểm từ nội dung tin nhắn
  Future<List<Attraction>> detectAttractionsFromMessage(String message) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      String lowerMessage = message.toLowerCase();
      List<Attraction> detectedAttractions = [];

      for (Attraction attraction in _sampleAttractions) {
        // Kiểm tra tên địa điểm
        if (lowerMessage.contains(attraction.name.toLowerCase())) {
          detectedAttractions.add(attraction);
          continue;
        }

        // Kiểm tra các từ khóa trong tags
        for (String tag in attraction.tags) {
          if (lowerMessage.contains(tag.toLowerCase())) {
            detectedAttractions.add(attraction);
            break;
          }
        }

        // Kiểm tra danh mục
        if (lowerMessage.contains(attraction.category.toLowerCase())) {
          detectedAttractions.add(attraction);
        }
      }

      return detectedAttractions.toSet().toList(); // Loại bỏ trùng lặp
    } catch (e) {
      print('Lỗi khi phát hiện địa điểm từ tin nhắn: $e');
      return [];
    }
  }

  /// Tính khoảng cách giữa hai điểm (đơn vị: mét)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Bán kính Trái Đất tính bằng mét

    double lat1Rad = point1.latitude * (3.14159265359 / 180);
    double lat2Rad = point2.latitude * (3.14159265359 / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (3.14159265359 / 180);
    double deltaLngRad = (point2.longitude - point1.longitude) * (3.14159265359 / 180);

    double a = pow(sin(deltaLatRad / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLngRad / 2), 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c; // Khoảng cách theo km
  }

  /// Lấy danh sách danh mục
  List<String> getCategories() {
    return [
      'religious',
      'historical',
      'market',
      'museum',
      'entertainment',
      'modern',
      'nature',
      'food',
      'shopping',
    ];
  }

  /// Lấy tên hiển thị của danh mục
  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'religious':
        return 'Tôn giáo';
      case 'historical':
        return 'Lịch sử';
      case 'market':
        return 'Chợ';
      case 'museum':
        return 'Bảo tàng';
      case 'entertainment':
        return 'Giải trí';
      case 'modern':
        return 'Hiện đại';
      case 'nature':
        return 'Thiên nhiên';
      case 'food':
        return 'Ẩm thực';
      case 'shopping':
        return 'Mua sắm';
      default:
        return category;
    }
  }
}