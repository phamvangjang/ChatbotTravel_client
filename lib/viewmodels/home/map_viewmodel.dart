import 'package:flutter/material.dart';
import 'package:mobilev2/services/home/tourist_attraction_service.dart';

import '../../models/tourist_attraction_model.dart';

class MapViewModel extends ChangeNotifier{
  final TouristAttractionService _touristAttractionService = TouristAttractionService();

  // State variables
  List<TouristAttraction> _allAttractions = [];
  List<TouristAttraction> _detectedAttractions = [];
  String _messageContent = '';
  int _conversationId = 0;
  bool _isLoading = false;
  String? _error;
  TouristAttraction? _selectedAttraction;
  List<TouristAttraction> _itinerary = [];

  // Getters
  List<TouristAttraction> get allAttractions => _allAttractions;
  List<TouristAttraction> get detectedAttractions => _detectedAttractions;
  String get messageContent => _messageContent;
  int get conversationId => _conversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TouristAttraction? get selectedAttraction => _selectedAttraction;
  List<TouristAttraction> get itinerary => _itinerary;

  // Khởi tạo ViewModel với nội dung tin nhắn và ID cuộc trò chuyện
  void initialize(String messageContent, int conversationId) {
    _messageContent = messageContent;
    _conversationId = conversationId;
    _loadAttractions();
    _extractLocationsFromMessage();
  }

  // Tải danh sách địa điểm du lịch
  void _loadAttractions() {
    _setLoading(true);

    try {
      _allAttractions = _touristAttractionService.getHcmcAttractions();
      notifyListeners();
    } catch (e) {
      _setError('Không thể tải danh sách địa điểm: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Trích xuất địa điểm từ nội dung tin nhắn
  void _extractLocationsFromMessage() {
    _setLoading(true);

    try {
      final detectedAttractions = <TouristAttraction>[];
      final content = _messageContent.toLowerCase();

      for (final attraction in _allAttractions) {
        // Kiểm tra xem địa điểm có được nhắc đến trong tin nhắn không
        if (attraction.matchesKeyword(content)) {
          detectedAttractions.add(attraction);
        }
      }

      _detectedAttractions = detectedAttractions;

      // Nếu có địa điểm được phát hiện, chọn địa điểm đầu tiên
      if (_detectedAttractions.isNotEmpty) {
        _selectedAttraction = _detectedAttractions.first;
      }

      notifyListeners();
    } catch (e) {
      _setError('Lỗi khi phân tích tin nhắn: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Chọn một địa điểm
  void selectAttraction(TouristAttraction attraction) {
    _selectedAttraction = attraction;
    notifyListeners();
  }

  // Thêm địa điểm vào lịch trình
  void addToItinerary(TouristAttraction attraction) {
    if (!_itinerary.contains(attraction)) {
      _itinerary.add(attraction);
      notifyListeners();
    }
  }

  // Xóa địa điểm khỏi lịch trình
  void removeFromItinerary(TouristAttraction attraction) {
    _itinerary.remove(attraction);
    notifyListeners();
  }

  // Sắp xếp lại lịch trình
  void reorderItinerary(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _itinerary.removeAt(oldIndex);
    _itinerary.insert(newIndex, item);
    notifyListeners();
  }

  // Lưu lịch trình
  Future<bool> saveItinerary() async {
    _setLoading(true);

    try {
      // Giả lập việc lưu lịch trình
      await Future.delayed(const Duration(seconds: 1));

      // Trong thực tế, bạn sẽ lưu lịch trình vào database hoặc cloud

      return true;
    } catch (e) {
      _setError('Không thể lưu lịch trình: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Tìm kiếm địa điểm
  void searchAttractions(String keyword) {
    if (keyword.isEmpty) {
      _detectedAttractions = [];
      notifyListeners();
      return;
    }

    _detectedAttractions = _touristAttractionService.searchAttractions(keyword);
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}