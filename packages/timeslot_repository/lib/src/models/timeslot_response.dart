import 'package:equatable/equatable.dart';
import 'package:timeslot_repository/timeslot_repository.dart';

class TimeslotResponse extends Equatable {
  TimeslotResponse({
    this.timeslots,
  });

  final List<Timeslot>? timeslots;

  factory TimeslotResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final timeslotsList = data.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      return Timeslot.fromJson(map);
    }).toList();

    return TimeslotResponse(
      timeslots: timeslotsList,
    );
  }

  @override
  List<Object?> get props => [timeslots];
}
