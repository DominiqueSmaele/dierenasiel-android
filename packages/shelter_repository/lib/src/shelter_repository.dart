import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShelterRepository {
  final storage = const FlutterSecureStorage();
  ShelterResponse _cachedShelters = ShelterResponse(shelters: [], meta: {});

  Future<ShelterResponse> getShelters({
    required int perPage,
    String? cursor,
    bool refresh = false,
  }) async {
    try {
      if (_cachedShelters.shelters!.isNotEmpty && !refresh)
        return _cachedShelters;

      final parameters = <String, String>{
        'per_page': perPage.toString(),
        if (cursor != null) 'cursor': cursor,
      };

      final url = Uri.parse(dotenv.env['API'] ?? '')
          .replace(path: '/api/shelters', queryParameters: parameters);
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
      final shelterResponse = ShelterResponse.fromJson(jsonResponse);

      if (_cachedShelters.shelters!.isNotEmpty) {
        return _cachedShelters = _cachedShelters.copyWith(
          shelters: List.of(_cachedShelters.shelters!)
            ..addAll(shelterResponse.shelters!),
          meta: shelterResponse.meta,
        );
      }

      return _cachedShelters = shelterResponse;
    } catch (e) {
      throw e;
    }
  }

  Future<ShelterResponse> searchShelters(
      {required int perPage, String? cursor, String? query}) async {
    try {
      final parameters = <String, String>{
        'per_page': perPage.toString(),
        if (cursor != null) 'cursor': cursor,
        if (query != null) 'q': query,
      };

      final url = Uri.parse(dotenv.env['API'] ?? '')
          .replace(path: '/api/shelters', queryParameters: parameters);
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

      return ShelterResponse.fromJson(jsonResponse);
    } catch (e) {
      throw e;
    }
  }

  Future<ShelterResponse> getSheltersTimeslots() async {
    try {
      final url = Uri.parse(dotenv.env['API'] ?? '')
          .replace(path: '/api/shelters/timeslots');
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

      return ShelterResponse.fromJson(jsonResponse);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void clearCachedShelters() {
    _cachedShelters = ShelterResponse(shelters: [], meta: {});
  }
}
