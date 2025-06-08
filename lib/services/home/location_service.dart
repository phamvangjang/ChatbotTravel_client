import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  /// Lấy vị trí hiện tại của người dùng
  Future<Position?> getCurrentLocation() async {
    try {
      // Kiểm tra xem dịch vụ định vị có được bật không
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Dịch vụ định vị chưa được bật');
      }

      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn');
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return position;
    } catch (e) {
      print('Lỗi khi lấy vị trí hiện tại: $e');
      return null;
    }
  }

  /// Lấy vị trí hiện tại dưới dạng LatLng
  Future<LatLng?> getCurrentLatLng() async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }

  /// Tính khoảng cách giữa hai điểm (đơn vị: mét)
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Tính khoảng cách giữa hai điểm (đơn vị: km)
  double calculateDistanceInKm(LatLng point1, LatLng point2) {
    return calculateDistance(point1, point2) / 1000;
  }

  /// Kiểm tra xem hai điểm có gần nhau không (trong bán kính cho trước)
  bool isNearby(LatLng point1, LatLng point2, double radiusInMeters) {
    return calculateDistance(point1, point2) <= radiusInMeters;
  }

  /// Lấy stream vị trí để theo dõi thay đổi vị trí
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Cập nhật khi di chuyển ít nhất 10m
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Kiểm tra quyền truy cập vị trí
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Yêu cầu quyền truy cập vị trí
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Kiểm tra xem dịch vụ định vị có được bật không
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Mở cài đặt vị trí
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Mở cài đặt ứng dụng
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Lấy vị trí cuối cùng đã biết
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Lỗi khi lấy vị trí cuối cùng: $e');
      return null;
    }
  }

  /// Định dạng tọa độ thành chuỗi
  String formatCoordinates(LatLng location, {int decimals = 6}) {
    return '${location.latitude.toStringAsFixed(decimals)}, ${location.longitude.toStringAsFixed(decimals)}';
  }

  /// Chuyển đổi từ Position sang LatLng
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  /// Tính bearing (hướng) giữa hai điểm
  double calculateBearing(LatLng start, LatLng end) {
    return Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}
