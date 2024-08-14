part of 'animal_bloc.dart';

enum AnimalStatus { initial, success, failure, refresh }

final class AnimalState extends Equatable {
  const AnimalState({
    this.status = AnimalStatus.initial,
    this.animals = const <Animal>[],
    this.filteredAnimals = const <Animal>[],
    this.hasReachedMax = false,
  });

  final AnimalStatus status;
  final List<Animal> animals;
  final List<Animal> filteredAnimals;
  final bool hasReachedMax;

  AnimalState copyWith({
    AnimalStatus? status,
    List<Animal>? animals,
    List<Animal>? filteredAnimals,
    bool? hasReachedMax,
    bool? refresh,
  }) {
    return AnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      filteredAnimals: filteredAnimals ?? this.filteredAnimals,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [status, animals, filteredAnimals, hasReachedMax];
}