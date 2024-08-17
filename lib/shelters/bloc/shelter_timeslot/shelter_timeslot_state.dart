part of 'shelter_timeslot_bloc.dart';

enum ShelterTimeslotStatus { initial, success, failure }

final class ShelterTimeslotState extends Equatable {
  const ShelterTimeslotState({
    this.status = ShelterTimeslotStatus.initial,
    this.shelters = const <Shelter>[],
  });

  final ShelterTimeslotStatus status;
  final List<Shelter> shelters;

  ShelterTimeslotState copyWith({
    ShelterTimeslotStatus? status,
    List<Shelter>? shelters,
  }) {
    return ShelterTimeslotState(
      status: status ?? this.status,
      shelters: shelters ?? this.shelters,
    );
  }

  @override
  List<Object> get props => [status, shelters];
}
