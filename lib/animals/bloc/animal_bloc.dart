import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:type_repository/type_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'animal_event.dart';
part 'animal_state.dart';

const throttleDuration = Duration(milliseconds: 100);
const refreshDelay = Duration(milliseconds: 500);
const cooldownDuration = Duration(seconds: 5);

const animalLimit = 12;

String? cursor;
String? searchCursor;

List<Type>? types;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  AnimalBloc(
      {required AnimalRepository animalRepository,
      required TypeRepository typeRepository})
      : _animalRepository = animalRepository,
        _typeRepository = typeRepository,
        super(const AnimalState()) {
    on<AnimalFetched>(
      _onAnimalFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<AnimalRefreshed>(
      _onAnimalRefreshed,
      transformer: throttleDroppable(cooldownDuration),
    );
    on<AnimalSearched>(
      _onAnimalSearched,
    );
    on<AnimalTypeSelected>(
      _onAnimalTypeSelected,
    );
    on<AnimalClearSearched>(
      _onAnimalClearSearched,
    );
  }

  final AnimalRepository _animalRepository;
  final TypeRepository _typeRepository;

  Future<void> _onAnimalFetched(
      AnimalFetched event, Emitter<AnimalState> emit) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == AnimalStatus.initial ||
          state.status == AnimalStatus.refresh) {
        final animalResponse =
            await _animalRepository.getAnimals(perPage: animalLimit);
        final typeResponse = await _typeRepository.getTypes();

        if (animalResponse.animals!.isEmpty) {
          return emit(state.copyWith(status: AnimalStatus.empty));
        }

        types = typeResponse.types;

        cursor = animalResponse.meta['next_cursor'];

        return emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: animalResponse.animals,
            types: types,
            hasReachedMax: cursor == null,
          ),
        );
      }

      final response = await _animalRepository.getAnimals(
          perPage: animalLimit, cursor: cursor, refresh: true);

      cursor = response.meta['next_cursor'];

      if (response.animals?.isNotEmpty ?? false) {
        emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: response.animals,
            hasReachedMax: cursor == null,
          ),
        );
      } else {
        emit(state.copyWith(hasReachedMax: true));
      }
    } catch (_) {
      emit(state.copyWith(status: AnimalStatus.failure));
    }
  }

  Future<void> _onAnimalRefreshed(
      AnimalRefreshed event, Emitter<AnimalState> emit) async {
    cursor = null;
    searchCursor = null;

    _animalRepository.clearCachedAnimals();

    emit(
      state.copyWith(
        status: AnimalStatus.refresh,
        animals: [],
        searchedAnimals: [],
        filteredAnimals: [],
        types: [],
        hasReachedMax: false,
        selectedType: null,
      ),
    );

    await Future.delayed(refreshDelay);

    add(AnimalFetched());
  }

  Future<void> _onAnimalSearched(
      AnimalSearched event, Emitter<AnimalState> emit) async {
    final query = event.query.toLowerCase();

    try {
      final response = await _animalRepository.searchAnimals(
          perPage: animalLimit, cursor: searchCursor, query: query);

      if (response.animals!.isEmpty) {
        return emit(state.copyWith(status: AnimalStatus.notFound));
      }

      searchCursor = response.meta['next_cursor'];

      if (state.selectedType != null) {
        List<Animal> filteredAnimals = response.animals!;

        filteredAnimals = filteredAnimals
            .where((animal) => animal.type.id == state.selectedType)
            .toList();

        if (filteredAnimals.isEmpty) {
          return emit(state.copyWith(
              status: AnimalStatus.notFound,
              searchedAnimals: response.animals));
        }

        return emit(
          state.copyWith(
            status: AnimalStatus.success,
            filteredAnimals: filteredAnimals,
            hasReachedMax: searchCursor == null,
          ),
        );
      }

      emit(
        state.copyWith(
          status: AnimalStatus.success,
          searchedAnimals: response.animals,
          hasReachedMax: searchCursor == null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AnimalStatus.failure));
    }
  }

  void _onAnimalTypeSelected(
      AnimalTypeSelected event, Emitter<AnimalState> emit) {
    if (event.typeId == null) {
      return emit(
        state.copyWith(
          status: AnimalStatus.success,
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
          status: AnimalStatus.notFound, selectedType: event.typeId));
    }

    emit(
      state.copyWith(
        status: AnimalStatus.success,
        filteredAnimals: filteredAnimals,
        selectedType: event.typeId,
      ),
    );
  }

  Future<void> _onAnimalClearSearched(
      AnimalClearSearched event, Emitter<AnimalState> emit) async {
    searchCursor = null;

    if (state.selectedType != null) {
      final filteredAnimals = state.animals
          .where((animal) => animal.type.id == state.selectedType)
          .toList();

      if (filteredAnimals.isEmpty) {
        return emit(
            state.copyWith(status: AnimalStatus.notFound, searchedAnimals: []));
      }

      return emit(
        state.copyWith(
          status: AnimalStatus.success,
          searchedAnimals: [],
          filteredAnimals: filteredAnimals,
        ),
      );
    }

    emit(
      state.copyWith(
        status: AnimalStatus.success,
        searchedAnimals: [],
        filteredAnimals: [],
        hasReachedMax: cursor == null,
      ),
    );
  }
}
