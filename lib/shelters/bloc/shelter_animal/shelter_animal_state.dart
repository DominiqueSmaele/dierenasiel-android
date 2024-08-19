part of 'shelter_animal_bloc.dart';

enum ShelterAnimalStatus { initial, success, failure, empty, notFound }

final class ShelterAnimalState extends Equatable {
  const ShelterAnimalState({
    this.status = ShelterAnimalStatus.initial,
    this.animals = const <Animal>[],
    this.searchedAnimals = const <Animal>[],
    this.filteredAnimals = const <Animal>[],
    this.types = const <Type>[],
    this.hasReachedMax = false,
    this.selectedType,
    this.query,
  });

  final ShelterAnimalStatus status;
  final List<Animal> animals;
  final List<Animal> searchedAnimals;
  final List<Animal> filteredAnimals;
  final List<Type> types;
  final bool hasReachedMax;
  final int? selectedType;
  final String? query;

  ShelterAnimalState copyWith({
    ShelterAnimalStatus? status,
    List<Animal>? animals,
    List<Animal>? searchedAnimals,
    List<Animal>? filteredAnimals,
    List<Type>? types,
    bool? hasReachedMax,
    bool? refresh,
    int? selectedType,
    String? query,
  }) {
    return ShelterAnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      searchedAnimals: searchedAnimals ?? this.searchedAnimals,
      filteredAnimals: filteredAnimals ?? this.filteredAnimals,
      types: types ?? this.types,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedType: selectedType,
      query: query,
    );
  }

  @override
  List<Object?> get props => [
        status,
        animals,
        searchedAnimals,
        filteredAnimals,
        hasReachedMax,
        types,
        selectedType,
        query,
      ];
}
