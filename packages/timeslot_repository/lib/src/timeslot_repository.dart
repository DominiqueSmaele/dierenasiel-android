import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimeslotRepository {
  final storage = const FlutterSecureStorage();

  Future<TimeslotResponse> getUserTimeslots() async {
    try {
      final url = Uri.parse(dotenv.env['API'] ?? '')
          .replace(path: '/api/user/timeslots');
      final token = await storage.read(key: 'token');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Connection': 'Keep-Alive',
        },
      );

      if (response.statusCode != 200) {
        final jsonResponse = jsonDecode(response.body);

        throw ApiException(jsonResponse['message'] ?? '');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      return TimeslotResponse.fromJson(jsonResponse);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> deleteTimeslotUser({
    required int id,
  }) async {
    try {
      final parameters = <String, String>{
        'id': id.toString(),
      };

      final url = Uri.parse(dotenv.env['API'] ?? '')
          .replace(path: '/api/timeslot/user', queryParameters: parameters);
      final token = await storage.read(key: 'token');

      final response = await http.delete(
        url,
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Connection': 'Keep-Alive',
        },
      );

      if (response.statusCode != 204) {
        final jsonResponse = jsonDecode(response.body);

        throw ApiException(jsonResponse['message'] ?? '');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> bookTimeslotUser({
    required int id,
  }) async {
    try {
      final parameters = <String, String>{
        'id': id.toString(),
      };

      final url = Uri.parse(dotenv.env['API'] ?? '')
          .replace(path: '/api/timeslot/user', queryParameters: parameters);
      final token = await storage.read(key: 'token');

      final response = await http.patch(
        url,
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Connection': 'Keep-Alive',
        },
      );

      if (response.statusCode != 200) {
        final jsonResponse = jsonDecode(response.body);

        throw ApiException(jsonResponse['message'] ?? '');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
