import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/itinerary_item.dart';
import 'api_service.dart';

class ItineraryService {
  static const String baseUrl = 'http://localhost:5000/api'; // TODO: Update with actual API URL

  // Lưu lịch trình vào database
  Future<bool> saveItinerary({
    required List<ItineraryItem> itinerary,
    required DateTime selectedDate,
    required int userId,
  }) async {
    try {
      print('💾 Đang gửi dữ liệu lên server...');
      
      // Chuẩn bị dữ liệu để gửi lên server
      final List<Map<String, dynamic>> itineraryData = itinerary.map((item) {
        return {
          'attraction_id': item.attraction.id,
          'visit_time': item.visitTime.toIso8601String(),
          'estimated_duration': item.estimatedDuration.inMinutes,
          'notes': item.notes,
        };
      }).toList();

      final requestData = {
        'user_id': userId,
        'selected_date': selectedDate.toIso8601String(),
        'itinerary_items': itineraryData,
      };

      print('📤 Dữ liệu gửi lên server:');
      print(json.encode(requestData));

      // Gửi request lên server
      final response = await http.post(
        Uri.parse(ApiService.createItineraryUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('📥 Response từ server: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Lưu lịch trình thành công!');
        return true;
      } else {
        print('❌ Lỗi khi lưu lịch trình: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception khi lưu lịch trình: $e');
      return false;
    }
  }

  // Lấy lịch trình của user
  Future<List<ItineraryItem>> getUserItineraries(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/itineraries'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ItineraryItem.fromJson(json)).toList();
      } else {
        print('❌ Lỗi khi lấy lịch trình: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception khi lấy lịch trình: $e');
      return [];
    }
  }

  // Xóa lịch trình
  Future<bool> deleteItinerary(int itineraryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/itineraries/$itineraryId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Exception khi xóa lịch trình: $e');
      return false;
    }
  }
} 