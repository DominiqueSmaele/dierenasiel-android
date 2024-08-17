import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:type_repository/type_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'shelter_animal_event.dart';
part 'shelter_animal_state.dart';

const throttleDuration = Duration(milliseconds: 100);
const cooldownDuration = Duration(seconds: 5);

const shelterAnimalLimit = 12;

String? cursor;
String? searchCursor;

List<Type>? types;

EventTransformer<E> shelterAnimalThrottleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ShelterAnimalBloc extends Bloc<ShelterAnimalEvent, ShelterAnimalState> {
  ShelterAnimalBloc(
      {required shelter,
      required AnimalRepository animalRepository,
      required TypeRepository typeRepository})
      : _animalRepository = animalRepository,
        _typeRepository = typeRepository,
        _shelter = shelter,
        super(const ShelterAnimalState()) {
    on<ShelterAnimalFetched>(
      _onShelterAnimalFetched,
      transformer: shelterAnimalThrottleDroppable(throttleDuration),
    );
    on<ShelterAnimalSearched>(
      _onShelterAnimalSearched,
    );
    on<ShelterAnimalTypeSelected>(
      _onShelterAnimalTypeSelected,
    );
    on<ShelterAnimalClearSearched>(
      _onShelterAnimalClearSearched,
    );
  }

  final AnimalRepository _animalRepository;
  final TypeRepository _typeRepository;
  final Shelter _shelter;

  Future<void> _onShelterAnimalFetched(
      ShelterAnimalFetched event, Emitter<ShelterAnimalState> emit) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == ShelterAnimalStatus.initial) {
        final response = await _animalRepository.getShelterAnimals(
            shelterId: _shelter.id, perPage: shelterAnimalLimit);
        final typeResponse = await _typeRepository.getTypes();

        if (response.animals!.isEmpty) {
          return emit(state.copyWith(status: ShelterAnimalStatus.empty));
        }

        types = typeResponse.types;

        cursor = response.meta['next_cursor'];

        return emit(
          state.copyWith(
            status: ShelterAnimalStatus.success,
            animals: response.animals,
            types: types,
            hasReachedMax: cursor == null,
          ),
        );
      }

      final response = await _animalRepository.getShelterAnimals(
          shelterId: _shelter.id, perPage: shelterAnimalLimit, cursor: cursor);

      cursor = response.meta['next_cursor'];

      if (response.animals?.isNotEmpty ?? false) {
        emit(
          state.copyWith(
            status: ShelterAnimalStatus.success,
            animals: List.of(state.animals)..addAll(response.animals!),
            hasReachedMax: cursor == null,
          ),
        );
      } else {
        emit(state.copyWith(hasReachedMax: true));
      }
    } catch (_) {
      emit(state.copyWith(status: ShelterAnimalStatus.failure));
    }
  }

  Future<void> _onShelterAnimalSearched(
      ShelterAnimalSearched event, Emitter<ShelterAnimalState> emit) async {
    final query = event.query.toLowerCase();

    try {
      final response = await _animalRepository.searchShelterAnimals(
          shelterId: _shelter.id,
          perPage: shelterAnimalLimit,
          cursor: searchCursor,
          query: query);

      if (response.animals!.isEmpty) {
        return emit(state.copyWith(status: ShelterAnimalStatus.notFound));
      }

      searchCursor = response.meta['next_cursor'];

      if (state.selectedType != null) {
        List<Animal> filteredAnimals = response.animals!;

        filteredAnimals = filteredAnimals
            .where((animal) => animal.type.id == state.selectedType)
            .toList();

        if (filteredAnimals.isEmpty) {
          return emit(state.copyWith(
              status: ShelterAnimalStatus.notFound,
              searchedAnimals: response.animals));
        }

        return emit(
          state.copyWith(
            status: ShelterAnimalStatus.success,
            filteredAnimals: filteredAnimals,
            hasReachedMax: searchCursor == null,
          ),
        );
      }

      emit(
        state.copyWith(
          status: ShelterAnimalStatus.success,
          searchedAnimals: response.animals,
          hasReachedMax: searchCursor == null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ShelterAnimalStatus.failure));
    }
  }

  void _onShelterAnimalTypeSelected(
      ShelterAnimalTypeSelected event, Emitter<ShelterAnimalState> emit) {
    if (event.typeId == null) {
      return emit(
        state.copyWith(
          status: ShelterAnimalStatus.success,
          filteredAnimals: [],
          selectedType: null,
        ),
      );
    }

    final filteredAnimals = (state.searchedAnimals.isNotEmpty
            ? state.searchedAnimals
            : state.animals)
        .where((animal) => animal.type.id == event.typeId)
        .toList();

    if (filteredAnimals.isEmpty) {
      return emit(state.copyWith(
          status: ShelterAnimalStatus.notFound, selectedType: event.typeId));
    }

    emit(
      state.copyWith(
        status: ShelterAnimalStatus.success,
        filteredAnimals: filteredAnimals,
        selectedType: event.typeId,
      ),
    );
  }

  Future<void> _onShelterAnimalClearSearched(ShelterAnimalClearSearched event,
      Emitter<ShelterAnimalState> emit) async {
    searchCursor = null;

    if (state.selectedType != null) {
      final filteredAnimals = state.animals
          .where((animal) => animal.type.id == state.selectedType)
          .toList();

      if (filteredAnimals.isEmpty) {
        return emit(state.copyWith(
            status: ShelterAnimalStatus.notFound, searchedAnimals: []));
      }

      return emit(
        state.copyWith(
          status: ShelterAnimalStatus.success,
          searchedAnimals: [],
          filteredAnimals: filteredAnimals,
        ),
      );
    }

    emit(
      state.copyWith(
        status: ShelterAnimalStatus.success,
        searchedAnimals: [],
        filteredAnimals: [],
        hasReachedMax: cursor == null,
      ),
    );
  }
}
