import 'package:equatable/equatable.dart';

final class Country extends Equatable {
  const Country({
    required this.id,
    required this.code,
  });

  final int id;
  final String code;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      code: json['code'] as String,
    );
  }

  @override
  List<Object> get props => [id, code];
}
