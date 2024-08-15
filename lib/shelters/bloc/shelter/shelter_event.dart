part of 'shelter_bloc.dart';

sealed class ShelterEvent extends Equatable {
  const ShelterEvent();

  @override
  List<Object?> get props => [];
}

final class ShelterFetched extends ShelterEvent {}

final class ShelterRefreshed extends ShelterEvent {}

final class ShelterSearched extends ShelterEvent {
  const ShelterSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ShelterClearSearched extends ShelterEvent {}