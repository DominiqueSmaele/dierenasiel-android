part of 'shelter_timeslot_bloc.dart';

sealed class ShelterTimeslotEvent extends Equatable {
  const ShelterTimeslotEvent();

  @override
  List<Object?> get props => [];
}

final class ShelterTimeslotFetched extends ShelterTimeslotEvent {}
