import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;

  @override
  List<Object> get props => [id, firstname, lastname, email];

  static const empty = User(id: 0, firstname: '', lastname: '', email: '');
}
