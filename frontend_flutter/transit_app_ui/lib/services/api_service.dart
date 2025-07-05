import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../models/route_result.dart';

class ApiService {
  // For Android emulator, use 10.0.2.2 to refer to your computer's localhost.
  // For iOS simulator, you can use 'localhost' or '127.0.0.1'.
  final String baseUrl = "http://127.0.0.1:5002/api"; 

  // Fetches the list of all stations from the backend
  Future<List<Station>> getStations() async {
    final response = await http.get(Uri.parse('$baseUrl/stations'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Station> stations = body.map((dynamic item) => Station.fromJson(item)).toList();
      return stations;
    } else {
      throw Exception('Failed to load stations');
    }
  }

  // Fetches the list of all stations from the backend
    Future<RouteResult> findRoute(String startStationId, String endStationId, String preference) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'start_station_id': startStationId,
        'end_station_id': endStationId,
        'preference': preference,
      }),
    );

    if (response.statusCode == 200) {
      return RouteResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorBody['error'] ?? 'Failed to find route');
    }
  }
}