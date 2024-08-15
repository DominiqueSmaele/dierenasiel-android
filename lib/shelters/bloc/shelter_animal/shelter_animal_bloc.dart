import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'shelter_animal_event.dart';
part 'shelter_animal_state.dart';


const shelterAnimalThrottleDuration = Duration(milliseconds: 100);
const shelterAnimalCooldownDuration = Duration(seconds: 10);

const shelterAnimalLimit = 12;

String? shelterAnimalCursor;
String? shelterAnimalFilterCursor;

EventTransformer<E> shelterAnimalThrottleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ShelterAnimalBloc extends Bloc<ShelterAnimalEvent, ShelterAnimalState> {
  ShelterAnimalBloc({required shelter, required AnimalRepository animalRepository}) :
    _animalRepository = animalRepository,
    _shelter = shelter,
    super(const ShelterAnimalState()) {
      on<ShelterAnimalFetched>(
        _onShelterAnimalFetched,
        transformer: shelterAnimalThrottleDroppable(shelterAnimalThrottleDuration),
      );
      on<ShelterAnimalSearched>(
        _onShelterAnimalSearched,
        transformer: shelterAnimalThrottleDroppable(shelterAnimalCooldownDuration),
      );
      on<ShelterAnimalClearSearched>(
        _onShelterAnimalClearSearched,
      );
    }

    final AnimalRepository _animalRepository;
    final Shelter _shelter;

    Future<void> _onShelterAnimalFetched(ShelterAnimalFetched event, Emitter<ShelterAnimalState> emit) async {
      if (state.hasReachedMax) return;

        try {
      if (state.status == ShelterAnimalStatus.initial) {
        final response = await _animalRepository.getShelterAnimals(shelterId: _shelter.id, perPage: shelterAnimalLimit);

        shelterAnimalCursor = response.meta['next_cursor'];

        return emit(
          state.copyWith(
            status: ShelterAnimalStatus.success,
            animals: response.animals,
            hasReachedMax: shelterAnimalCursor == null,
          ),
        );
      }

      final response = await _animalRepository.getShelterAnimals(shelterId: _shelter.id, perPage: shelterAnimalLimit, cursor: shelterAnimalCursor);

      shelterAnimalCursor = response.meta['next_cursor'];

      if (response.animals?.isNotEmpty ?? false) {
        emit(
          state.copyWith(
            status: ShelterAnimalStatus.success,
            animals: response.animals,
            hasReachedMax: shelterAnimalCursor == null,
          ),
        );
      } else {
        emit(state.copyWith(hasReachedMax: true));
      }
    } catch (_) {
      emit(state.copyWith(status: ShelterAnimalStatus.failure));
    } 
  }

  Future<void> _onShelterAnimalSearched(ShelterAnimalSearched event, Emitter<ShelterAnimalState> emit) async {
    final query = event.query.toLowerCase();

    try {
      final response = await _animalRepository.searchShelterAnimals(shelterId: _shelter.id, perPage: shelterAnimalLimit, cursor: shelterAnimalFilterCursor, query: query);

      if (response.animals!.isEmpty) {
        return emit(state.copyWith(status: ShelterAnimalStatus.notFound));
      }

      shelterAnimalFilterCursor = response.meta['next_cursor'];

      emit(
        state.copyWith(
          status: ShelterAnimalStatus.success,
          filteredAnimals: response.animals,
          hasReachedMax: shelterAnimalFilterCursor == null,
        ),
      );

    } catch (_) {
      emit(state.copyWith(status: ShelterAnimalStatus.failure));
    }
  }

  Future<void> _onShelterAnimalClearSearched(ShelterAnimalClearSearched event, Emitter<ShelterAnimalState> emit) async {
    shelterAnimalFilterCursor = null;

    emit(
      state.copyWith(
        status: ShelterAnimalStatus.success,
        filteredAnimals: [],
        hasReachedMax: shelterAnimalCursor == null,
      ),
    );
  }
}