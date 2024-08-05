import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final String email;

  const User(
    this.id,
    this.firstname,
    this.lastname,
    this.email,
  );

  @override
  List<Object> get props => [id, firstname, lastname, email];

  static const empty = User(0, '', '', '');
}