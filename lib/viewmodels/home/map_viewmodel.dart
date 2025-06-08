import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobilev2/services/home/tourist_attraction_service.dart';

import '../../models/itinerary_item.dart';
import '../../models/tourist_attraction_model.dart';

class MapViewModel extends ChangeNotifier {
  final TouristAttractionService _touristAttractionService =
      TouristAttractionService();
  final PolylinePoints _polylinePoints = PolylinePoints();

  // State variables
  List<TouristAttraction> _allAttractions = [];
  List<TouristAttraction> _detectedAttractions = [];
  String _messageContent = '';
  int _conversationId = 0;
  bool _isLoading = false;
  String? _error;
  TouristAttraction? _selectedAttraction;

  // Map related
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng _initialPosition = const LatLng(
    10.762622,
    106.660172,
  ); // TP.HCM center

  // Itinerary related
  List<ItineraryItem> _itinerary = [];
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<ItineraryItem>> _dailyItineraries = {};

  // Getters
  List<TouristAttraction> get allAttractions => _allAttractions;

  List<TouristAttraction> get detectedAttractions => _detectedAttractions;

  String get messageContent => _messageContent;

  int get conversationId => _conversationId;

  bool get isLoading => _isLoading;

  String? get error => _error;

  TouristAttraction? get selectedAttraction => _selectedAttraction;

  // Map getters
  GoogleMapController? get mapController => _mapController;

  Position? get currentPosition => _currentPosition;

  Set<Marker> get markers => _markers;

  Set<Polyline> get polylines => _polylines;

  LatLng get initialPosition => _initialPosition;

  // Itinerary getters
  List<ItineraryItem> get itinerary => _itinerary;

  DateTime get selectedDate => _selectedDate;

  Map<DateTime, List<ItineraryItem>> get dailyItineraries => _dailyItineraries;

  List<ItineraryItem> get todayItinerary =>
      _dailyItineraries[_getDateKey(_selectedDate)] ?? [];

  // Khởi tạo ViewModel
  void initialize(String messageContent, int conversationId) {
    _messageContent = messageContent;
    _conversationId = conversationId;
    _loadAttractions();
    _extractLocationsFromMessage();
    _getCurrentLocation();
  }

  // Tải danh sách địa điểm du lịch
  void _loadAttractions() {
    _setLoading(true);

    try {
      _allAttractions = _touristAttractionService.getHcmcAttractions();
      _updateMarkers();
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
        if (attraction.matchesKeyword(content)) {
          detectedAttractions.add(attraction);
        }
      }

      _detectedAttractions = detectedAttractions;

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

  // Map controller methods
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  // Chọn một địa điểm
  void selectAttraction(TouristAttraction attraction) {
    _selectedAttraction = attraction;

    // Di chuyển camera đến địa điểm được chọn
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(attraction.latitude, attraction.longitude),
          15.0,
        ),
      );
    }

    notifyListeners();
  }

  // Itinerary methods
  void selectDate(DateTime date) {
    _selectedDate = date;
    _drawRoute();
    notifyListeners();
  }

  // Thêm địa điểm vào lịch trình
  void addToItinerary(
    TouristAttraction attraction, {
    DateTime? date,
    TimeOfDay? time,
  }) {
    final targetDate = date ?? _selectedDate;
    final visitTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      time?.hour ?? 9,
      time?.minute ?? 0,
    );

    final item = ItineraryItem(
      attraction: attraction,
      visitTime: visitTime,
      estimatedDuration: const Duration(hours: 2), // Mặc định 2 tiếng
    );

    final dateKey = _getDateKey(targetDate);
    if (!_dailyItineraries.containsKey(dateKey)) {
      _dailyItineraries[dateKey] = [];
    }

    _dailyItineraries[dateKey]!.add(item);
    _dailyItineraries[dateKey]!.sort(
      (a, b) => a.visitTime.compareTo(b.visitTime),
    );

    _updateMarkers();
    _drawRoute();
    notifyListeners();
  }

  // Xóa địa điểm khỏi lịch trình
  void removeFromItinerary(ItineraryItem item) {
    final dateKey = _getDateKey(item.visitTime);
    _dailyItineraries[dateKey]?.remove(item);

    if (_dailyItineraries[dateKey]?.isEmpty == true) {
      _dailyItineraries.remove(dateKey);
    }

    _updateMarkers();
    _drawRoute();
    notifyListeners();
  }

  void updateItineraryItem(ItineraryItem oldItem, ItineraryItem newItem) {
    final oldDateKey = _getDateKey(oldItem.visitTime);
    final newDateKey = _getDateKey(newItem.visitTime);

    // Xóa item cũ
    _dailyItineraries[oldDateKey]?.remove(oldItem);
    if (_dailyItineraries[oldDateKey]?.isEmpty == true) {
      _dailyItineraries.remove(oldDateKey);
    }

    // Thêm item mới
    if (!_dailyItineraries.containsKey(newDateKey)) {
      _dailyItineraries[newDateKey] = [];
    }
    _dailyItineraries[newDateKey]!.add(newItem);
    _dailyItineraries[newDateKey]!.sort(
      (a, b) => a.visitTime.compareTo(b.visitTime),
    );

    _drawRoute();
    notifyListeners();
  }

  // Sắp xếp lại lịch trình
  void reorderItinerary(int oldIndex, int newIndex) {
    final items = todayItinerary;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Cập nhật thời gian theo thứ tự mới
    for (int i = 0; i < items.length; i++) {
      final baseTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        9, // Bắt đầu từ 9h sáng
      );
      final newTime = baseTime.add(
        Duration(hours: i * 3),
      ); // Mỗi địa điểm cách nhau 3 tiếng

      items[i] = items[i].copyWith(visitTime: newTime);
    }

    _drawRoute();
    notifyListeners();
  }

  // Lưu lịch trình
  Future<bool> saveItinerary() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Trong thực tế, lưu vào database hoặc cloud storage
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

  // Vẽ tuyến đường giữa các địa điểm trong lịch trình
  Future<void> _drawRoute() async {
    if (todayItinerary.length < 2) {
      _polylines.clear();
      notifyListeners();
      return;
    }

    _polylines.clear();

    try {
      for (int i = 0; i < todayItinerary.length - 1; i++) {
        final start = todayItinerary[i].attraction;
        final end = todayItinerary[i + 1].attraction;

        final result = await _polylinePoints.getRouteBetweenCoordinates(
          dotenv.env['GOOGLE_MAP_API_KEY_FLUTTER_APP']!,
          PointLatLng(start.latitude, start.longitude),
          PointLatLng(end.latitude, end.longitude),
          travelMode: TravelMode.driving,
        );

        if (result.points.isNotEmpty) {
          final polylineCoordinates =
              result.points
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList();

          _polylines.add(
            Polyline(
              polylineId: PolylineId('route_$i'),
              color: Colors.blue,
              width: 5,
              points: polylineCoordinates,
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Không thể vẽ tuyến đường: $e');
    }
  }

  DateTime _getDateKey(DateTime selectedDate) {
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  }

  // Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('Dịch vụ vị trí chưa được bật');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Quyền truy cập vị trí bị từ chối');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Quyền truy cập vị trí bị từ chối vĩnh viễn');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _initialPosition = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _updateMarkers();
      notifyListeners();
    } catch (e) {
      _setError('Không thể lấy vị trí hiện tại: $e');
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Thêm marker vị trí hiện tại
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Thêm markers cho các địa điểm du lịch
    for (final attraction in _allAttractions) {
      _markers.add(
        Marker(
          markerId: MarkerId(attraction.id),
          position: LatLng(attraction.latitude, attraction.longitude),
          infoWindow: InfoWindow(
            title: attraction.name,
            snippet: attraction.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _isInItinerary(attraction)
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
          onTap: () => selectAttraction(attraction),
        ),
      );
    }

    notifyListeners();
  }

  // Helper methods
  bool _isInItinerary(TouristAttraction attraction) {
    return _dailyItineraries.values.any(
      (items) => items.any((item) => item.attraction.id == attraction.id),
    );
  }
}
