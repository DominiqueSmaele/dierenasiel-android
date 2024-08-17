import 'package:equatable/equatable.dart';

class OpeningPeriod extends Equatable {
  const OpeningPeriod({
    required this.id,
    required this.day,
    this.open,
    this.close,
  });

  final int id;
  final int day;
  final DateTime? open;
  final DateTime? close;

  factory OpeningPeriod.fromJson(Map<String, dynamic> json) {
    return OpeningPeriod(
      id: json['id'] as int,
      day: json['day'] as int,
      open:
          json['open'] != null ? DateTime.parse(json['open'] as String) : null,
      close: json['close'] != null
          ? DateTime.parse(json['close'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, day, open, close];
}
