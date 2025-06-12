import 'dart:convert'; // untuk json.decode
import 'package:http/http.dart' as http;
import '../models/activity.dart'; // import model Activity yang kamu buat

class ActivityService {
  final String baseUrl;

  // Constructor dengan default value baseUrl
  ActivityService({this.baseUrl = 'http://192.168.1.24:8000/api'});

  Future<List<Activity>> fetchActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/activities'), // baseUrl sudah termasuk /api
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);

      if (responseJson.containsKey('data') && responseJson['data'] is List) {
        final List<dynamic> dataList = responseJson['data'];
        return dataList.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception('Field "data" tidak ditemukan atau bukan list');
      }
    } else {
      throw Exception('Gagal memuat data aktivitas');
    }
  }
}
