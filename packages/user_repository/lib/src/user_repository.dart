import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_repository/src/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRepository {
  final storage = new FlutterSecureStorage();
  User? _user;

  Future<User?> getUser() async {
    if (_user != null) return _user;

    try {
      final url = Uri.parse('${dotenv.env['API']}/user/current');
      final token = await storage.read(key: 'token');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception('Failed to retrieve user...');
      }

      return _user = User(
        id: data['id'] as int,
        firstname: data['firstname'] as String,
        lastname: data['lastname'] as String,
        email: data['email'] as String,
      );
    } catch (e) {
      throw e;
    }
  }
}