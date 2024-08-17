import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_repository/user_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRepository {
  final storage = new FlutterSecureStorage();
  User? _user;

  Future<User?> getUser({
    bool verify = false,
  }) async {
    if (_user != null && !verify) return _user;

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

      if (response.statusCode != 200) {
        throw ApiException(jsonResponse['message'] ?? '');
      }

      final data = jsonResponse['data'] as Map<String, dynamic>;

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

  Future<User> updateUser({
    required String firstname,
    required String lastname,
    required String email,
  }) async {
    try {
      final url = Uri.parse('${dotenv.env['API']}/user');
      final token = await storage.read(key: 'token');

      final response = await http.patch(
        url,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ApiException(jsonResponse['message'] ?? '');
      }

      final data = jsonResponse['data'] as Map<String, dynamic>;

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

  Future<void> updateUserPassword({
    required String password,
    required String repeatPassword,
  }) async {
    try {
      final url = Uri.parse('${dotenv.env['API']}/user/password');
      final token = await storage.read(key: 'token');

      final response = await http.patch(
        url,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'password': password,
          'repeat_password': repeatPassword,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ApiException(jsonResponse['message'] ?? '');
      }
    } catch (e) {
      throw (e);
    }
  }
}
