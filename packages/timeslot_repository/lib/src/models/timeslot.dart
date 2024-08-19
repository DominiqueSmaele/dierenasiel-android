import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:shelter_repository/shelter_repository.dart';

class Timeslot extends Equatable {
  const Timeslot(
      {required this.id,
      required this.date,
      required this.startTime,
      required this.endTime,
      this.shelter});

  final int id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Shelter? shelter;

  factory Timeslot.fromJson(Map<String, dynamic> json) {
    return Timeslot(
      id: json['id'] as int,
      date: _convertStringToDatetime(json['date'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      shelter: json['shelter'] != null
          ? Shelter.fromJson(json['shelter'] as Map<String, dynamic>)
          : null,
    );
  }

  static DateTime _convertStringToDatetime(String date) {
    return DateFormat('dd-MM-yyyy').parse(date);
  }

  @override
  List<Object?> get props => [id, date, startTime, endTime, shelter];
}
