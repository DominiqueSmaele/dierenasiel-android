import 'dart:async';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final storage = new FlutterSecureStorage();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
      final url = Uri.parse('${dotenv.env['API']}/login');

      try {
        final response = await http.post(
          url, 
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json'
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password
          }),
        );

        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode != 200) {
          throw ApiException(jsonResponse['message'] ?? '');
        }

        print(jsonResponse['token']);

        await storage.write(key: 'token', value: jsonResponse['token']);

        _controller.add(AuthenticationStatus.authenticated);
      } catch (e) {
        throw e;
      }
  }

  Future<void> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${dotenv.env['API']}/register');

    try {
      final response = await http.post(
        url, 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        body: jsonEncode(<String, String>{
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

        if (response.statusCode != 201) {
          throw ApiException(jsonResponse['message'] ?? '');
        }

      print(jsonResponse['token']);

      await storage.write(key: 'token', value: jsonResponse['token']);

      _controller.add(AuthenticationStatus.authenticated);
    } catch (e) {
      throw e;
    }
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}