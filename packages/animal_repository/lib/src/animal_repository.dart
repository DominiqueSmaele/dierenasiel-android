import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnimalRepository {
  final storage = const FlutterSecureStorage();

  Future<AnimalResponse> getAnimals({
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
      
      final url = Uri.parse(dotenv.env['WEB'] ?? '').replace(path: '/api/animals', queryParameters: parameters);
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

      final animals = AnimalResponse.fromJson(jsonResponse);
      return animals;
    } catch (e) {
      throw e;
    }
  }
}