part of 'shelter_timeslot_bloc.dart';

sealed class ShelterTimeslotEvent extends Equatable {
  const ShelterTimeslotEvent();

  @override
  List<Object?> get props => [];
}

class ShelterTimeslotUserBook extends ShelterTimeslotEvent {
  final Shelter shelter;
  final Timeslot timeslot;

  const ShelterTimeslotUserBook(this.shelter, this.timeslot);

  @override
  List<Object?> get props => [shelter, timeslot];
}

final class ShelterTimeslotFetched extends ShelterTimeslotEvent {}
