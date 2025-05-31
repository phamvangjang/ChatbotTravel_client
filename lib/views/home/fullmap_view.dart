// import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
//
// class MapView extends StatefulWidget {
//   const MapView({super.key});
//
//   @override
//   State<MapView> createState() => _MapViewState();
// }
//
// class _MapViewState extends State<MapView> {
//   MapboxMap? _mapboxMap;
//
//   // QUAN TRỌNG: Thay thế bằng Mapbox access token của bạn
//   final String _myAccessToken = "YOUR_MAPBOX_ACCESS_TOKEN";
//
//   void _onMapCreated(MapboxMap mapboxMap) {
//     _mapboxMap = mapboxMap;
//     print("Map created successfully!");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Sửa lỗi 1: Khởi tạo ResourceOptions đúng cách.
//     // Đây là một đối tượng, không phải là một phương thức của _MapViewState.
//     // Dòng này có thể tương ứng với lỗi ở dòng 69 của bạn.
//     final mapResourceOptions = ResourceOptions(accessToken: _myAccessToken);
//
//     return Scaffold(
//       body: MapWidget(
//           key: const ValueKey("mapWidgetBasicFixed"),
//           // Sửa lỗi 2: Đảm bảo 'resourceOptions' là tham số đúng của MapWidget.
//           // Dòng này có thể tương ứng với lỗi ở dòng 74 của bạn.
//           resourceOptions: mapResourceOptions, // Sử dụng biến đã tạo ở trên
//           cameraOptions: CameraOptions(
//             // Sửa lỗi 3: Truyền trực tiếp đối tượng Point, không phải .toJson()
//             // Dòng này có thể tương ứng với lỗi ở dòng 78 của bạn.
//             center: Point(coordinates: Position(105.8522, 21.0285)), // Ví dụ: Hồ Gươm, Hà Nội
//             zoom: 14.0,
//           ),
//           styleUri: MapboxStyles.MAPBOX_STREETS,
//           onMapCreated: _onMapCreated,
//           onStyleLoadedListener: (eventData) {
//             print("Style đã được tải.");
//           },
//           onMapIdleListener: (eventData) {
//             print("Bản đồ đang ở trạng thái nghỉ (idle).");
//           },
//           onMapLoadErrorListener: (eventData) {
//             print("Lỗi tải bản đồ: ${eventData.message}");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Lỗi tải bản đồ: ${eventData.message}")),
//             );
//           }
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     print("MapView disposed.");
//     super.dispose();
//   }
// }
