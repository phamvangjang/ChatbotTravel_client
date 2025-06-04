import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

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

class MapViewScreenv2 extends StatefulWidget {
  const MapViewScreenv2({super.key});

  @override
  State<MapViewScreenv2> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreenv2> {
  MapWidget? _mapWidget;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  geo.Position? _currentPosition;
  bool _isLoading = false;
  bool _locationPermissionGranted = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _initializeMap();
  }

  void _initializeMap() {
    _mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      cameraOptions: CameraOptions(
        // center: Point(coordinates: [106.721981, 10.795769]),
        zoom: 12,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onMapLoadErrorListener: (error) {
        print("============== Map load error ============== $error");
        setState(() {
          _locationError = "Map failed to load: $error";
        });
      },
    );
  }

  Future<void> _checkLocationPermission() async {
    try {
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();

      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Location permissions are permanently denied";
          _locationPermissionGranted = false;
        });
        return;
      }

      if (permission == geo.LocationPermission.denied) {
        setState(() {
          _locationError = "Location permissions are denied";
          _locationPermissionGranted = false;
        });
        return;
      }

      setState(() {
        _locationPermissionGranted = true;
        _locationError = null;
      });
    } catch (e) {
      setState(() {
        _locationError = "Error checking location permission: $e";
        _locationPermissionGranted = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      await _checkLocationPermission();
      if (!_locationPermissionGranted) return;
    }

    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      geo.Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      await _updateMapLocation(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationError = "Failed to get location: $e";
      });
    }
  }

  Future<void> _updateMapLocation(position) async {
    if (_mapboxMap == null) return;

    // Move camera to current location
    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: position(position.longitude, position.latitude),
        ),
        zoom: 15,
      ),
      MapAnimationOptions(duration: 1000),
    );

    // Clear existing markers
    await _pointAnnotationManager?.deleteAll();

    // Add current location marker
    await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: position(position.longitude, position.latitude),
        ),
        iconImage: "current-location-marker",
        iconSize: 1.5,
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    try {
      // Load marker images
      final markerImage = await loadMarkerImage('assets/marker.png');
      final locationMarkerImage = await _createLocationMarkerImage();

      // Register the images with the map style
      await _mapboxMap?.style.addStyleImage(
        "custom-marker",
        1.0,
        markerImage,
        false,
        [],
        [],
        null,
      );

      await _mapboxMap?.style.addStyleImage(
        "current-location-marker",
        1.0,
        locationMarkerImage,
        false,
        [],
        [],
        null,
      );

      // // Create the point annotation manager
      // _pointAnnotationManager =
      //     await _mapboxMap?.annotations.createPointAnnotationManager();
      //
      // // Add initial marker
      // await _pointAnnotationManager?.create(
      //   PointAnnotationOptions(
      //     geometry: Point(coordinates: Position(106.721981, 10.795769)),
      //     iconImage: "custom-marker",
      //     iconSize: 2.0,
      //   ),
      // );
    } catch (e) {
      print("Error setting up map: $e");
      setState(() {
        _locationError = "Error setting up map: $e";
      });
    }
  }

  Future<MbxImage> _createLocationMarkerImage() async {
    // Create a simple blue circle for current location
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    const size = 40.0;
    const radius = size / 2;

    // Draw white border
    canvas.drawCircle(const Offset(radius, radius), radius, strokePaint);
    // Draw blue center
    canvas.drawCircle(const Offset(radius, radius), radius - 2, paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());

    final ByteData? rawData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (rawData == null) {
      throw Exception("Failed to create location marker image");
    }

    return MbxImage(
      width: image.width,
      height: image.height,
      data: rawData.buffer.asUint8List(),
    );
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: const Text(
            'This app needs location permission to show your current position on the map. Please enable location permission in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapbox Location"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed:
                _locationPermissionGranted
                    ? _getCurrentLocation
                    : _showLocationSettings,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          _mapWidget ?? const Center(child: CircularProgressIndicator()),

          // Location info panel
          if (_currentPosition != null || _locationError != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_locationError != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_currentPosition != null) ...[
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Current Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "location",
            onPressed:
                _locationPermissionGranted
                    ? _getCurrentLocation
                    : _showLocationSettings,
            backgroundColor: Colors.blue,
            child:
                _isLoading
                    ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                    : const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "refresh",
            onPressed: () {
              setState(() {
                _locationError = null;
              });
              _initializeMap();
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pointAnnotationManager?.deleteAll();
    _mapboxMap?.dispose();
    super.dispose();
  }
}
