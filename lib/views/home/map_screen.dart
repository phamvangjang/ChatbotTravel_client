// import 'package:flutter/material.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
//
// class MapScreen extends StatefulWidget {
//   final List<LocationPoint> locations;
//
//   const MapScreen({super.key, required this.locations});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   late MapboxMapController mapController;
//
//   static const String accessToken =
//       'pk.eyJ1IjoidmFuZ2lhbmc0Nzg5IiwiYSI6ImNtYTY0YTc3bzBxdDUyaXE1c3hxcmM3Y3YifQ.APhUinusY7r_S5mEQarhIg';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Map View")),
//       body: MapboxMap(
//         accessToken: accessToken,
//         initialCameraPosition: CameraPosition(
//           target:
//               widget.locations.isNotEmpty
//                   ? LatLng(widget.locations[0].lat, widget.locations[0].lng)
//                   : const LatLng(10.7769, 106.7009), // Default: HCM
//           zoom: 12,
//         ),
//         onMapCreated: _onMapCreated,
//         myLocationEnabled: true,
//         myLocationTrackingMode: MyLocationTrackingMode.Tracking,
//         compassEnabled: true,
//       ),
//     );
//   }
//
//   void _onMapCreated(MapboxMapController controller) {
//     mapController = controller;
//     for (var location in widget.locations) {
//       mapController.addSymbol(
//         SymbolOptions(
//           geometry: LatLng(location.lat, location.lng),
//           iconImage: "marker-15",
//           // Built-in icon
//           iconSize: 1.5,
//           textField: location.name,
//           textOffset: const Offset(0, 1.5),
//           textSize: 12,
//         ),
//       );
//     }
//   }
// }
//
// class LocationPoint {
//   final String name;
//   final double lat;
//   final double lng;
//
//   LocationPoint({required this.name, required this.lat, required this.lng});
// }
