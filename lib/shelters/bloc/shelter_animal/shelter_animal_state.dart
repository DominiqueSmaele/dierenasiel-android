part of 'shelter_animal_bloc.dart';

enum ShelterAnimalStatus { initial, success, failure, notFound }

final class ShelterAnimalState extends Equatable {
  const ShelterAnimalState({
    this.status = ShelterAnimalStatus.initial,
    this.animals = const <Animal>[],
    this.filteredAnimals = const <Animal>[],
    this.hasReachedMax = false,
  });

  final ShelterAnimalStatus status;
  final List<Animal> animals;
  final List<Animal> filteredAnimals;
  final bool hasReachedMax;

  ShelterAnimalState copyWith({
    ShelterAnimalStatus? status,
    List<Animal>? animals,
    List<Animal>? filteredAnimals,
    bool? hasReachedMax,
    bool? refresh,
  }) {
    return ShelterAnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      filteredAnimals: filteredAnimals ?? this.filteredAnimals,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }  

  @override
  List<Object> get props => [status, animals, filteredAnimals, hasReachedMax];
}