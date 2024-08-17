part of 'timeslots_bloc.dart';

enum TimeslotStatus { initial, success, failure, refresh, empty }

final class TimeslotState extends Equatable {
  const TimeslotState({
    this.status = TimeslotStatus.initial,
    this.timeslots = const <Timeslot>[],
  });

  final TimeslotStatus status;
  final List<Timeslot> timeslots;

  TimeslotState copyWith({
    TimeslotStatus? status,
    List<Timeslot>? timeslots,
    bool? hasReachedMax,
  }) {
    return TimeslotState(
      status: status ?? this.status,
      timeslots: timeslots ?? this.timeslots,
    );
  }

  @override
  List<Object> get props => [status, timeslots];
}
