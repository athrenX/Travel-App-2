import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelapp/models/location.dart';

class LocationService {
  final String baseUrl;

  LocationService({required this.baseUrl});

  Future<Location> fetchLocation(int id) async {
    final url = Uri.parse('$baseUrl/api/location/$id');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Location.fromJson(jsonData);
    } else {
      throw Exception('Failed to load location data');
    }
  }
}
