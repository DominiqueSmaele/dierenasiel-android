import 'package:equatable/equatable.dart';

final class Type extends Equatable {
  const Type({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object> get props => [id, name];
}
