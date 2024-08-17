part of 'timeslots_bloc.dart';

sealed class TimeslotEvent extends Equatable {
  const TimeslotEvent();

  @override
  List<Object?> get props => [];
}

final class TimeslotFetched extends TimeslotEvent {}

final class TimeslotRefreshed extends TimeslotEvent {}

class TimeslotUserDelete extends TimeslotEvent {
  final Timeslot timeslot;

  const TimeslotUserDelete(this.timeslot);

  @override
  List<Object?> get props => [timeslot];
}
