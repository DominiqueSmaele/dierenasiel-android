import 'package:equatable/equatable.dart';
import 'package:type_repository/type_repository.dart';

class TypeResponse extends Equatable {
  TypeResponse({
    this.types,
  });

  final List<Type>? types;

  factory TypeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final typesList = data.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      return Type.fromJson(map);
    }).toList();

    return TypeResponse(
      types: typesList,
    );
  }

  @override
  List<Object?> get props => [types];
}
