part of 'shelter_timeslot_bloc.dart';

enum ShelterTimeslotStatus { initial, success, failure, empty }

final class ShelterTimeslotState extends Equatable {
  const ShelterTimeslotState({
    this.status = ShelterTimeslotStatus.initial,
    this.shelters = const <Shelter>[],
    this.selectedShelter,
  });

  final ShelterTimeslotStatus status;
  final List<Shelter> shelters;
  final int? selectedShelter;

  ShelterTimeslotState copyWith({
    ShelterTimeslotStatus? status,
    List<Shelter>? shelters,
    int? selectedShelter,
  }) {
    return ShelterTimeslotState(
      status: status ?? this.status,
      shelters: shelters ?? this.shelters,
      selectedShelter: selectedShelter ?? this.selectedShelter,
    );
  }

  @override
  List<Object?> get props => [status, shelters, selectedShelter];
}
