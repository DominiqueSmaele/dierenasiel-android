import 'package:equatable/equatable.dart';

final class Quality extends Equatable {
  const Quality({
    required this.id,
    required this.name,
    required this.value,
  });

  final int id;
  final String name;
  final bool? value;

  factory Quality.fromJson(Map<String, dynamic> json) {
    return Quality(
      id: json['id'] as int,
      name: json['name'] as String,
      value: _convertIntoToBool(json['pivot']['value'] as int?),
    );
  }

  static bool? _convertIntoToBool(int? value) {
    switch (value) {
      case null:
        return null;
      case 0:
        return false;
      default:
        return true;
    }
  }

  @override
  List<Object?> get props => [id, name, value];
}
