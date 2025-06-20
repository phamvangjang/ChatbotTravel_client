import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  Future<List<double>?> getCoordinatesFromMapbox(String placeName) async {
    final accessToken = dotenv.env["MAPBOX_ACCESS_TOKEN"] ?? '';
    print("===============AccessToken=============== ");
    print(accessToken);
    final encoded = Uri.encodeComponent(placeName);
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json?access_token=$accessToken';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["features"] != null && data["features"].isNotEmpty) {
        final coords = data["features"][0]["geometry"]["coordinates"];
        return [coords[1], coords[0]]; // [lat, lng]
      }
    }
    return null;
  }
}
