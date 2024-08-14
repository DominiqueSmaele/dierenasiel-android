import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'shelter_event.dart';
part 'shelter_state.dart';

const throttleDuration = Duration(milliseconds: 100);
const shelterLimit = 12;
const refreshDelay = Duration(milliseconds: 500);
const cooldownDuration = Duration(seconds: 10);
String? cursor;
String? filterCursor;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ShelterBloc extends Bloc<ShelterEvent, ShelterState> {
  ShelterBloc({required ShelterRepository shelterRepository}) :
    _shelterRepository = shelterRepository,
    super(const ShelterState()) {
    on<ShelterFetched>(
      _onShelterFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ShelterRefreshed>(
      _onShelterRefreshed,
      transformer: throttleDroppable(cooldownDuration),
    );
    on<ShelterSearched>(
      _onShelterSearched,
    );
    on<ShelterClearSearched>(
      _onShelterClearSearched,
    );
  }

  final ShelterRepository _shelterRepository;

  Future<void> _onShelterFetched(ShelterFetched event, Emitter<ShelterState> emit) async {
    if (state.hasReachedMax) return;
    
    try {
      if (state.status == ShelterStatus.initial || state.status == ShelterStatus.refresh) {
        final response = await _shelterRepository.getShelters(perPage: shelterLimit);

        cursor = response.meta['next_cursor'];

        return emit(
          state.copyWith(
            status: ShelterStatus.success,
            shelters: response.shelters,
            hasReachedMax: cursor == null,
          ),
        );
      }

      final response = await _shelterRepository.getShelters(perPage: shelterLimit, cursor: cursor);

      cursor = response.meta['next_cursor'];

      if (response.shelters?.isNotEmpty ?? false) {
        emit(
          state.copyWith(
            status: ShelterStatus.success,
            shelters: List.of(state.shelters)..addAll(response.shelters!),
            hasReachedMax: cursor == null,
          ),
        );
      } else {
        emit(state.copyWith(hasReachedMax: true));
      }
    } catch (_) {
      emit(state.copyWith(status: ShelterStatus.failure));
    }
  }

  Future<void> _onShelterRefreshed(ShelterRefreshed event, Emitter<ShelterState> emit) async {
    cursor = null;
  
    emit(
      state.copyWith(
        status: ShelterStatus.refresh,
        shelters: [],
        filteredShelters: [],
        hasReachedMax: false,
      ),
    );

    await Future.delayed(refreshDelay);

    add(ShelterFetched());
  }

  Future<void> _onShelterSearched(ShelterSearched event, Emitter<ShelterState> emit) async {
    final query = event.query.toLowerCase();

    try {
      final response = await _shelterRepository.searchShelters(perPage: shelterLimit, cursor: filterCursor, query: query);

      filterCursor = response.meta['next_cursor'];

      emit(
        state.copyWith(
          status: ShelterStatus.success,
          filteredShelters: response.shelters,
          hasReachedMax: filterCursor == null,
        ),
      );

    } catch (_) {
      emit(state.copyWith(status: ShelterStatus.failure));
    }
  }

  Future<void> _onShelterClearSearched(ShelterClearSearched event, Emitter<ShelterState> emit) async {
    filterCursor = null;

    emit(
      state.copyWith(
        status: ShelterStatus.success,
        filteredShelters: [],
        hasReachedMax: cursor == null,
      ),
    );
  }
}