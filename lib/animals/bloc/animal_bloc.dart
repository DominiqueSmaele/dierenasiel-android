import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'animal_event.dart';
part 'animal_state.dart';

const throttleDuration = Duration(milliseconds: 100);
const animalLimit = 12;
const refreshDelay = Duration(milliseconds: 500);
const cooldownDuration = Duration(seconds: 10);
String? cursor;
String? filterCursor;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  AnimalBloc({required AnimalRepository animalRepository}) : 
    _animalRepository = animalRepository,
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
    on<AnimalClearSearched>(
      _onAnimalClearSearched,
    );
  }

  final AnimalRepository _animalRepository;

  Future<void> _onAnimalFetched(AnimalFetched event, Emitter<AnimalState> emit) async {
    if (state.hasReachedMax) return;
    
    try {
      if (state.status == AnimalStatus.initial || state.status == AnimalStatus.loading) {
        final response = await _animalRepository.getAnimals(perPage: animalLimit);

        cursor = response.meta['next_cursor'];

        return emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: response.animals,
            hasReachedMax: cursor == null,
          ),
        );
      }

      final response = await _animalRepository.getAnimals(perPage: animalLimit, cursor: cursor);

      cursor = response.meta['next_cursor'];

      if (response.animals?.isNotEmpty ?? false) {
        emit(
          state.copyWith(
            status: AnimalStatus.success,
            animals: List.of(state.animals)..addAll(response.animals!),
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

  Future<void> _onAnimalRefreshed(AnimalRefreshed event, Emitter<AnimalState> emit) async {
    cursor = null;
  
    emit(
      state.copyWith(
        status: AnimalStatus.loading,
        animals: [],
        filteredAnimals: [],
        hasReachedMax: false,
      ),
    );

    await Future.delayed(refreshDelay);

    add(AnimalFetched());
  }

  Future<void> _onAnimalSearched(AnimalSearched event, Emitter<AnimalState> emit) async {
    final query = event.query.toLowerCase();

    try {
      final response = await _animalRepository.getAnimals(perPage: animalLimit, cursor: filterCursor, query: query);

      filterCursor = response.meta['next_cursor'];

      emit(
        state.copyWith(
          status: AnimalStatus.success,
          filteredAnimals: response.animals,
          hasReachedMax: filterCursor == null,
        ),
      );

    } catch (_) {
      emit(state.copyWith(status: AnimalStatus.failure));
    }
  }

  Future<void> _onAnimalClearSearched(AnimalClearSearched event, Emitter<AnimalState> emit) async {
    filterCursor = null;

    emit(
      state.copyWith(
        status: AnimalStatus.success,
        filteredAnimals: [],
        hasReachedMax: cursor == null,
      ),
    );
  }
}