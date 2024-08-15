import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnimalRepository {
  final storage = const FlutterSecureStorage();
  AnimalResponse _cachedAnimals = AnimalResponse(animals: [], meta: {});

  Future<AnimalResponse> getAnimals({
    required int perPage,
    String? cursor,
    bool refresh = false,
  }) async {
    try {
      if (_cachedAnimals.animals!.isNotEmpty && !refresh) return _cachedAnimals;

      final parameters = <String, String>{
        'per_page': perPage.toString(),
        if (cursor != null) 'cursor': cursor,
      };
      
      final url = Uri.parse(dotenv.env['API'] ?? '').replace(path: '/api/animals', queryParameters: parameters);
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
      final animalResponse = AnimalResponse.fromJson(jsonResponse);

      if (_cachedAnimals.animals!.isNotEmpty) {
        return _cachedAnimals = _cachedAnimals.copyWith(
          animals: List.of(_cachedAnimals.animals!)..addAll(animalResponse.animals!),
          meta: animalResponse.meta,
        );
      }
      
      return _cachedAnimals = animalResponse;
    } catch (e) {
      throw e;
    }
  }

  Future<AnimalResponse> searchAnimals({
    required int perPage,
    String? cursor,
    String? query
  }) async {
    try {
      final parameters = <String, String>{
        'per_page': perPage.toString(),
        if (cursor != null) 'cursor': cursor,
        if (query != null) 'q': query,
      };
      
      final url = Uri.parse(dotenv.env['API'] ?? '').replace(path: '/api/animals', queryParameters: parameters);
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

      return AnimalResponse.fromJson(jsonResponse);
    } catch (e) {
      throw e;
    }
  }

  Future<AnimalResponse> getShelterAnimals({
    required int shelterId,
    required int perPage,
    String? cursor,
  }) async {
    try {
      final parameters = <String, String>{
        'per_page': perPage.toString(),
        if (cursor != null) 'cursor': cursor,
      };
      
      final url = Uri.parse(dotenv.env['API'] ?? '').replace(path: '/api/shelter/${shelterId}/animals', queryParameters: parameters);
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

      return AnimalResponse.fromJson(jsonResponse);
    } catch (e) {
      throw e;
    }
  }

  Future<AnimalResponse> searchShelterAnimals({
    required int shelterId,
    required int perPage,
    String? cursor,
    String? query
  }) async {
    try {
      final parameters = <String, String>{
        'per_page': perPage.toString(),
        if (cursor != null) 'cursor': cursor,
        if (query != null) 'q': query,
      };
      
      final url = Uri.parse(dotenv.env['API'] ?? '').replace(path: '/api/shelter/${shelterId}/animals', queryParameters: parameters);
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

      return AnimalResponse.fromJson(jsonResponse);
    } catch (e) {
      throw e;
    }
  }

  void clearCachedAnimals() {
    _cachedAnimals = AnimalResponse(animals: [], meta: {});
  }
}