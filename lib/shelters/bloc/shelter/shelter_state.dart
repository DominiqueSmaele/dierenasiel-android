part of 'shelter_bloc.dart';

enum ShelterStatus { initial, success, failure, refresh, notFound }

final class ShelterState extends Equatable {
  const ShelterState({
    this.status = ShelterStatus.initial,
    this.shelters = const <Shelter>[],
    this.filteredShelters = const <Shelter>[],
    this.hasReachedMax = false,
  });

  final ShelterStatus status;
  final List<Shelter> shelters;
  final List<Shelter> filteredShelters;
  final bool hasReachedMax;

  ShelterState copyWith({
    ShelterStatus? status,
    List<Shelter>? shelters,
    List<Shelter>? filteredShelters,
    bool? hasReachedMax,
  }) {
    return ShelterState(
      status: status ?? this.status,
      shelters: shelters ?? this.shelters,
      filteredShelters: filteredShelters ?? this.filteredShelters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [status, shelters, filteredShelters, hasReachedMax];
}