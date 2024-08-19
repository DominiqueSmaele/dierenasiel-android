part of 'animal_bloc.dart';

enum AnimalStatus { initial, success, failure, refresh, empty, notFound }

final class AnimalState extends Equatable {
  const AnimalState({
    this.status = AnimalStatus.initial,
    this.animals = const <Animal>[],
    this.searchedAnimals = const <Animal>[],
    this.filteredAnimals = const <Animal>[],
    this.types = const <Type>[],
    this.hasReachedMax = false,
    this.selectedType,
    this.query,
  });

  final AnimalStatus status;
  final List<Animal> animals;
  final List<Animal> searchedAnimals;
  final List<Animal> filteredAnimals;
  final List<Type> types;
  final bool hasReachedMax;
  final int? selectedType;
  final String? query;

  AnimalState copyWith({
    AnimalStatus? status,
    List<Animal>? animals,
    List<Animal>? searchedAnimals,
    List<Animal>? filteredAnimals,
    List<Type>? types,
    bool? hasReachedMax,
    bool? refresh,
    int? selectedType,
    String? query,
  }) {
    return AnimalState(
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
        types,
        hasReachedMax,
        selectedType,
        query,
      ];
}
