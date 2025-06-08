import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../models/attraction_model.dart';
import '../../models/itinerary_item.dart';
import '../../services/home/attraction_service.dart';
import '../../services/home/location_service.dart';

class MapViewModel extends ChangeNotifier {
  // Services
  final LocationService _locationService = LocationService();
  final AttractionService _attractionService = AttractionService();

  // Mapbox access token - THAY ĐỔI TOKEN NÀY
  final String mapboxAccessToken = dotenv.env["MAPBOX_ACCESS_TOKEN"]!;

  // Mapbox style URL
  final String mapboxStyleUrl = 'mapbox://styles/mapbox/streets-v12';

  // Mapbox directions API URL
  final String directionsApiUrl =
      'https://api.mapbox.com/directions/v5/mapbox/walking';

  // Trạng thái
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  // Vị trí hiện tại
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  // Vị trí ban đầu (mặc định: Hồ Chí Minh)
  LatLng _initialPosition = LatLng(10.7769, 106.7009);

  LatLng get initialPosition => _initialPosition;

  // Nội dung tin nhắn
  String _messageContent = '';

  String get messageContent => _messageContent;

  // ID cuộc trò chuyện
  int _conversationId = 0;

  int get conversationId => _conversationId;

  // Danh sách địa điểm du lịch
  List<Attraction> _detectedAttractions = [];

  List<Attraction> get detectedAttractions => _detectedAttractions;

  // Địa điểm được chọn
  Attraction? _selectedAttraction;

  Attraction? get selectedAttraction => _selectedAttraction;

  // Markers trên bản đồ
  List<Marker> _markers = [];

  List<Marker> get markers => _markers;

  // Polylines trên bản đồ
  List<Polyline> _polylines = [];

  List<Polyline> get polylines => _polylines;

  // Lịch trình theo ngày
  final Map<DateTime, List<ItineraryItem>> _dailyItineraries = {};

  Map<DateTime, List<ItineraryItem>> get dailyItineraries => _dailyItineraries;

  // Ngày được chọn
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  // Lịch trình của ngày được chọn
  List<ItineraryItem> get todayItinerary {
    final dateKey = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return _dailyItineraries[dateKey] ?? [];
  }

  // Controller cho MapboxMap
  MapController? _mapController;

  MapController? get mapController => _mapController;

  // Khởi tạo
  Future<void> initialize(String messageContent, int conversationId) async {
    _messageContent = messageContent;
    _conversationId = conversationId;
    _isLoading = true;
    notifyListeners();

    // Tạo MapController
    _mapController = MapController();

    // Lấy vị trí hiện tại
    await _getCurrentLocation();

    // Phát hiện địa điểm từ nội dung tin nhắn
    await _detectAttractionsFromMessage();

    _isLoading = false;
    notifyListeners();
  }

  // Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      if (_currentPosition != null) {
        _initialPosition = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Phát hiện địa điểm từ nội dung tin nhắn
  Future<void> _detectAttractionsFromMessage() async {
    try {
      if (_messageContent.isNotEmpty) {
        _detectedAttractions = await _attractionService
            .detectAttractionsFromMessage(_messageContent);
      } else {
        // Nếu không có tin nhắn, lấy địa điểm gần đó
        if (_currentPosition != null) {
          LatLng currentLatLng = LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          _detectedAttractions = await _attractionService.getNearbyAttractions(
            currentLatLng,
          );
        } else {
          // Lấy tất cả địa điểm
          _detectedAttractions = await _attractionService.getAllAttractions();
        }
      }

      // Tạo markers cho các địa điểm
      _updateMarkers();
    } catch (e) {
      print('Error detecting attractions: $e');
      // Fallback: lấy tất cả địa điểm
      _detectedAttractions = await _attractionService.getAllAttractions();
      _updateMarkers();
    }
  }

  // Cập nhật markers
  void _updateMarkers() {
    _markers = [];

    // Thêm marker cho vị trí hiện tại
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 40,
          height: 40,
          builder:
              (context) => Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 20,
                ),
              ),
        ),
      );
    }

    // Thêm markers cho các địa điểm
    for (var attraction in _detectedAttractions) {
      final isSelected = _selectedAttraction?.id == attraction.id;

      _markers.add(
        Marker(
          point: attraction.location,
          width: 40,
          height: 40,
          builder:
              (context) => GestureDetector(
                onTap: () => selectAttraction(attraction),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: isSelected ? 24 : 20,
                  ),
                ),
              ),
        ),
      );
    }

    notifyListeners();
  }

  // Chọn địa điểm
  Future<void> selectAttraction(Attraction attraction) async {
    _selectedAttraction = attraction;
    _updateMarkers();

    // Di chuyển bản đồ đến địa điểm được chọn
    if (_mapController != null) {
      _mapController!.move(attraction.location, 15.0);
    }

    // Vẽ đường đi từ vị trí hiện tại đến địa điểm được chọn
    if (_currentPosition != null) {
      await _getDirections(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        attraction.location,
      );
    }

    notifyListeners();
  }

  // Lấy chỉ đường từ Mapbox API
  Future<void> _getDirections(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$directionsApiUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&access_token=$mapboxAccessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];

          if (geometry != null && geometry['coordinates'] != null) {
            final List<dynamic> coords = geometry['coordinates'];
            final List<LatLng> points =
                coords.map((coord) {
                  return LatLng(coord[1], coord[0]);
                }).toList();

            _polylines = [
              Polyline(points: points, color: Colors.blue, strokeWidth: 4.0),
            ];

            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  // Khởi tạo MapController
  void onMapCreated() {
    _mapController ??= MapController();
    notifyListeners();
  }

  // Chọn ngày
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Thêm vào lịch trình
  void addToItinerary(
    Attraction attraction, {
    required DateTime date,
    required TimeOfDay time,
  }) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final visitTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final item = ItineraryItem(attraction: attraction, visitTime: visitTime);

    if (_dailyItineraries.containsKey(dateKey)) {
      _dailyItineraries[dateKey]!.add(item);
      // Sắp xếp theo thời gian
      _dailyItineraries[dateKey]!.sort(
        (a, b) => a.visitTime.compareTo(b.visitTime),
      );
    } else {
      _dailyItineraries[dateKey] = [item];
    }

    notifyListeners();
  }

  // Xóa khỏi lịch trình
  void removeFromItinerary(ItineraryItem item) {
    final dateKey = DateTime(
      item.visitTime.year,
      item.visitTime.month,
      item.visitTime.day,
    );

    if (_dailyItineraries.containsKey(dateKey)) {
      _dailyItineraries[dateKey]!.remove(item);

      if (_dailyItineraries[dateKey]!.isEmpty) {
        _dailyItineraries.remove(dateKey);
      }

      notifyListeners();
    }
  }

  // Cập nhật item trong lịch trình
  void updateItineraryItem(ItineraryItem oldItem, ItineraryItem newItem) {
    final oldDateKey = DateTime(
      oldItem.visitTime.year,
      oldItem.visitTime.month,
      oldItem.visitTime.day,
    );
    final newDateKey = DateTime(
      newItem.visitTime.year,
      newItem.visitTime.month,
      newItem.visitTime.day,
    );

    // Xóa item cũ
    if (_dailyItineraries.containsKey(oldDateKey)) {
      _dailyItineraries[oldDateKey]!.remove(oldItem);

      if (_dailyItineraries[oldDateKey]!.isEmpty) {
        _dailyItineraries.remove(oldDateKey);
      }
    }

    // Thêm item mới
    if (_dailyItineraries.containsKey(newDateKey)) {
      _dailyItineraries[newDateKey]!.add(newItem);
      _dailyItineraries[newDateKey]!.sort(
        (a, b) => a.visitTime.compareTo(b.visitTime),
      );
    } else {
      _dailyItineraries[newDateKey] = [newItem];
    }

    notifyListeners();
  }

  // Sắp xếp lại lịch trình
  void reorderItinerary(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final dateKey = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (_dailyItineraries.containsKey(dateKey)) {
      final item = _dailyItineraries[dateKey]!.removeAt(oldIndex);
      _dailyItineraries[dateKey]!.insert(newIndex, item);

      notifyListeners();
    }
  }

  // Lưu lịch trình
  Future<bool> saveItinerary() async {
    try {
      // TODO: Implement saving itinerary to backend
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      print('Error saving itinerary: $e');
      return false;
    }
  }

  // Lấy vị trí hiện tại (public method)
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    await _getCurrentLocation();
    _updateMarkers();

    // Di chuyển bản đồ đến vị trí hiện tại
    if (_currentPosition != null && _mapController != null) {
      _mapController!.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tìm kiếm địa điểm
  Future<void> searchAttractions(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      LatLng? currentLocation;
      if (_currentPosition != null) {
        currentLocation = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      _detectedAttractions = await _attractionService.searchAttractions(
        query,
        currentLocation: currentLocation,
      );
      _updateMarkers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error searching attractions: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy địa điểm theo danh mục
  Future<void> getAttractionsByCategory(String category) async {
    try {
      _isLoading = true;
      notifyListeners();

      LatLng? currentLocation;
      if (_currentPosition != null) {
        currentLocation = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      _detectedAttractions = await _attractionService.getAttractionsByCategory(
        category,
        currentLocation: currentLocation,
      );
      _updateMarkers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error getting attractions by category: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset selection
  void clearSelection() {
    _selectedAttraction = null;
    _polylines = [];
    _updateMarkers();
  }
}
