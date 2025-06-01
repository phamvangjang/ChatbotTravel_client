import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreen();
}

class _MapViewScreen extends State<MapViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapbox")),
      body: MapWidget(
        key: ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(106.721981, 10.795769)),
          zoom: 12,
        ),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: (MapboxMap mapboxMap) {},
      ),
    );
  }
}
