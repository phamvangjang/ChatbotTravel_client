import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilev2/views/home/fullmap_view.dart';
import '../../models/message_model.dart';
import '../../services/home/geocoding_service.dart';
import '../../views/home/map_view.dart';

class MainViewModel extends ChangeNotifier {
  GeocodingService geocodingService = GeocodingService();

  Future<List<Message>> loadMessages() async {
    final jsonString = await rootBundle.loadString('assets/messages.json');
    final jsonMap = json.decode(jsonString);
    final messages =
        (jsonMap['messages'] as List).map((e) => Message.fromJson(e)).toList();
    return messages;
  }

  Future<void> openMapWithMessageText(
    BuildContext context,
    String messageText,
  ) async {
    print(context);
    print(messageText);
    if (!messageText.contains("Địa điểm:")) return;

    final extracted = messageText.split("Địa điểm:")[1];
    final suggestions = extracted.split(",");
    final places = suggestions.map((e) => e.trim()).toList();

    final List<Map<String, dynamic>> locations = [];

    for (final place in places) {
      final coords = await geocodingService.getCoordinatesFromMapbox(place);
      if (coords != null) {
        locations.add({"name": place, "lat": coords[0], "lng": coords[1]});
      }
    }

    if (locations.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapScreen(locations: locations)),
    );
  }
}
