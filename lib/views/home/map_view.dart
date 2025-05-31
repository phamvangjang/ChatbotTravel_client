import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> locations;
  const MapScreen({super.key, required this.locations});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMap _mapboxMap;
  PointAnnotationManager? _annotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bản đồ địa điểm")),
      body: MapWidget(
        // resourceOptions: ResourceOptions(
        //   accessToken: "your_mapbox_access_token_here",
        // ),
        key: const ValueKey("mapView"),
        onMapCreated: _onMapCreated,
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(
              widget.locations[0]["lng"],
              widget.locations[0]["lat"],
            ),
          ),
          zoom: 13.5,
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(title: const Text("Bản đồ địa điểm")),
    //   body: MapWidget(
    //     key: const ValueKey("mapView"),
    //     onMapCreated: _onMapCreated,
    //     mapOptions: MapOptions( // Thêm MapOptions ở đây
    //       resourceOptions: ResourceOptions(
    //         accessToken: "your_mapbox_access_token_here",
    //         // Có thể thêm các tùy chọn khác nếu cần
    //       ),
    //       cameraOptions: CameraOptions(
    //         center: Point(
    //           coordinates: Position(
    //             widget.locations[0]["lng"],
    //             widget.locations[0]["lat"],
    //           ),
    //         ).toJson(), // Thêm .toJson() cho Point
    //         zoom: 13.5,
    //       ), pixelRatio: 12,
    //     ),
    //   ),
    // );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    for (final location in widget.locations) {
      await _addMarker(location["lat"], location["lng"], location["name"]);
    }
  }

  Future<void> _addMarker(double lat, double lng, String name) async {
    final imageBytes = await _loadMarkerImage("assets/marker.png");

    final options = PointAnnotationOptions(
      geometry: Point(coordinates: Position(lng, lat)),
      image: imageBytes,
      iconSize: 1.5,
      textField: name,
      textOffset: [0.0, 2.0],
      textSize: 14.0,
    );

    await _annotationManager?.create(options);
  }

  Future<Uint8List> _loadMarkerImage(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }
}

