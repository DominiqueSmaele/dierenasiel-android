import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:type_repository/type_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TypeRepository {
  final storage = const FlutterSecureStorage();

  Future<TypeResponse> getTypes() async {
    try {
      final url =
          Uri.parse(dotenv.env['API'] ?? '').replace(path: '/api/types');
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

      return TypeResponse.fromJson(jsonResponse);
    } catch (e) {
      throw e;
    }
  }
}
