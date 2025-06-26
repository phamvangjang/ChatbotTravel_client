import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/itinerary_item.dart';
import '../../models/itinerary.dart';
import '../api_service.dart';

class ItineraryService {

  // Lưu lịch trình vào database
  Future<bool> saveItinerary({
    required List<ItineraryItem> itinerary,
    required DateTime selectedDate,
    required int userId,
    required String title,
  }) async {
    try {
      print('💾 Đang gửi dữ liệu lên server...');

      // Chuẩn bị dữ liệu để gửi lên server
      final List<Map<String, dynamic>> itineraryData =
          itinerary.map((item) {
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
        'title': title,
        'itinerary_items': itineraryData,
      };

      print('📤 Dữ liệu gửi lên server:');
      print(json.encode(requestData));

      // Gửi request lên server
      final response = await http.post(
        Uri.parse(ApiService.createItineraryUrl),
        headers: {'Content-Type': 'application/json'},
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
  Future<List<Itinerary>> getUserItineraries(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getItineraryByUserIdUrl(userId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => Itinerary.fromJson(e)).toList();
      } else {
        print('❌ Lỗi khi lấy lịch trình: [31m${response.statusCode}[0m');
        return [];
      }
    } catch (e) {
      print('❌ Exception khi lấy lịch trình: $e');
      return [];
    }
  }

  // Xóa lịch trình
  Future<bool> deleteItinerary(int itineraryId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiService.removeItineraryUrl(itineraryId, userId)),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Exception khi xóa lịch trình: $e');
      return false;
    }
  }
}
