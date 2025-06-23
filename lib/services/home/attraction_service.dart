import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:latlong2/latlong.dart';
import 'package:mobilev2/scape/attraction_scape.dart';

import '../../models/attraction_model.dart';
import '../../services/api_service.dart';

class AttractionService{
  static final AttractionService _instance = AttractionService._internal();
  final AttractionScape _attractionScape = AttractionScape();
  factory AttractionService() => _instance;
  AttractionService._internal();

  /// Lấy danh sách địa điểm gần vị trí hiện tại
  Future<List<Attraction>> getNearbyAttractions(
      LatLng currentLocation, {
        double radiusInKm = 20.0,
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

  /// Tìm kiếm địa điểm theo từ khóa thông qua API
  Future<List<Attraction>> searchAttractions(
      String query, {
        LatLng? currentLocation,
        String language = 'vietnamese',
        int limit = 20,
      }) async {
    try {
      print("🔍 Searching attractions for query: $query");
      print("🌐 Language: $language");
      print("📊 Limit: $limit");

      // Chuẩn bị query parameters
      final queryParams = {
        'q': query,
        'language': language,
        'limit': limit.toString(),
      };

      // Tạo URL với query parameters
      final uri = Uri.parse(ApiService.searchAttractionsUrl).replace(queryParameters: queryParams);
      
      print("📤 API Request URL: $uri");

      // Gọi API thực tế
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print("📥 API Response Status: ${response.statusCode}");
      print("📥 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Kiểm tra status
        if (responseData['status'] == 'success') {
          final List<dynamic> attractionsData = responseData['data'] ?? [];
          return _parseAttractionsFromApiResponse(attractionsData);
        } else {
          print('❌ API returned error: ${responseData['message']}');
          return [];
        }
      } else {
        print('❌ API request failed: ${response.statusCode}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi khi tìm kiếm địa điểm: $e');
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

      return _attractionScape.hcmAttractions.firstWhere(
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

      List<Attraction> results = _attractionScape.hcmAttractions
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
      return List.from(_attractionScape.hcmAttractions);
    } catch (e) {
      print('Lỗi khi lấy tất cả địa điểm: $e');
      return [];
    }
  }

  /// Phát hiện địa điểm từ danh sách places thông qua API
  Future<List<Attraction>> detectAttractionsFromMessage(List<String> places, {String? language}) async {
    try {
      print("ℹ️ detectAttractionsFromMessage with places: ${places.toString()}");
      print("ℹ️ Language: $language");

      // Chuẩn bị request body theo format API
      final requestBody = {
        "places": places,
        "language": language ?? 'vietnamese',
      };

      print("📤 API Request: ${jsonEncode(requestBody)}");

      // Gọi API thực tế
      final response = await http.post(
        Uri.parse(ApiService.detectAttractionsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("📥 API Response Status: ${response.statusCode}");
      print("📥 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Kiểm tra status
        if (responseData['status'] == 'success') {
          final List<dynamic> attractionsData = responseData['data'] ?? [];
          return _parseAttractionsFromApiResponse(attractionsData);
        } else {
          print('❌ API returned error: ${responseData['message']}');
          return [];
        }
      } else {
        print('❌ API request failed: ${response.statusCode}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ℹ️ Lỗi khi phát hiện địa điểm từ places: $e');
      return [];
    }
  }

  /// Parse attractions từ response API
  List<Attraction> _parseAttractionsFromApiResponse(List<dynamic> attractionsData) {
    try {
      List<Attraction> attractions = [];

      for (final attractionData in attractionsData) {
        try {
          final attraction = Attraction(
            id: attractionData['id'] ?? '',
            name: attractionData['name'] ?? '',
            address: attractionData['address'] ?? '',
            description: attractionData['description'] ?? '',
            imageUrl: attractionData['image_url'] ?? '',
            rating: (attractionData['rating'] ?? 0.0).toDouble(),
            location: LatLng(
              (attractionData['latitude'] ?? 0.0).toDouble(),
              (attractionData['longitude'] ?? 0.0).toDouble(),
            ),
            category: attractionData['category'] ?? 'tourist_attraction',
            tags: List<String>.from(attractionData['tags'] ?? []),
            openingHours: attractionData['opening_hours'],
            price: attractionData['price']?.toDouble(),
            phoneNumber: attractionData['phone'],
            website: attractionData['website'],
          );
          attractions.add(attraction);
          print("✅ Parsed attraction: ${attraction.name}");
        } catch (e) {
          print('❌ Lỗi parse attraction: $e');
        }
      }

      print("📊 Total attractions parsed: ${attractions.length}");
      return attractions;
    } catch (e) {
      print('❌ Lỗi parse API response: $e');
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
}