import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<MbxImage> loadMarkerImage(String assetPath) async {
  final ByteData byteData = await rootBundle.load(assetPath);
  final Uint8List uint8List = byteData.buffer.asUint8List();

  // Decode image
  final ui.Codec codec = await ui.instantiateImageCodec(uint8List);
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  // Convert image to RGBA bytes
  final ByteData? rawData = await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );

  if (rawData == null) {
    throw Exception("Failed to convert image to raw RGBA");
  }

  return MbxImage(
    width: image.width,
    height: image.height,
    data: rawData.buffer.asUint8List(),
  );
}

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreen();
}

class _MapViewScreen extends State<MapViewScreen> {
  MapWidget? _mapWidget;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    _mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(106.721981, 10.795769)),
        zoom: 12,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onMapLoadErrorListener: (error) {
        print("============== Map load error ============== $error");
      },
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Load marker image
    final markerImage = await loadMarkerImage('assets/marker.png');

    // Register the image with the map style
    await _mapboxMap?.style.addStyleImage(
      "custom-marker",
      1.0,
      markerImage,
      false,
      [],
      [],
      null,
    );

    // Create the point annotation manager
    _pointAnnotationManager =
        await _mapboxMap?.annotations.createPointAnnotationManager();

    // Add a marker
    await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(106.721981, 10.795769)),
        iconImage: "custom-marker",
        iconSize: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapbox")),
      body: _mapWidget ?? const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _pointAnnotationManager?.deleteAll();
    _mapboxMap?.dispose();
    super.dispose();
  }
}
