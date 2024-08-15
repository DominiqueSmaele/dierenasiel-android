part of 'shelter_animal_bloc.dart';

sealed class ShelterAnimalEvent extends Equatable {
  const ShelterAnimalEvent();

  @override
  List<Object?> get props => [];
}

final class ShelterAnimalFetched extends ShelterAnimalEvent {}

final class ShelterAnimalSearched extends ShelterAnimalEvent {
  const ShelterAnimalSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ShelterAnimalClearSearched extends ShelterAnimalEvent {}