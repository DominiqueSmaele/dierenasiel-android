part of 'animal_bloc.dart';

sealed class AnimalEvent extends Equatable {
  const AnimalEvent();

  @override
  List<Object?> get props => [];
}

final class AnimalFetched extends AnimalEvent {}

final class AnimalRefreshed extends AnimalEvent {}

final class AnimalSearched extends AnimalEvent {
  const AnimalSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class AnimalTypeSelected extends AnimalEvent {
  final int? typeId;

  const AnimalTypeSelected(this.typeId);

  @override
  List<Object?> get props => [typeId];
}

final class AnimalClearSearched extends AnimalEvent {}
