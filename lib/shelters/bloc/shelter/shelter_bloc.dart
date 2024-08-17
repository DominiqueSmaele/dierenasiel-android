import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'shelter_event.dart';
part 'shelter_state.dart';

const shelterThrottleDuration = Duration(milliseconds: 100);
const shelterCooldownDuration = Duration(seconds: 5);
const refreshDelay = Duration(milliseconds: 500);

const shelterLimit = 12;

String? shelterCursor;
String? shelterFilterCursor;

EventTransformer<E> shelterThrottleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ShelterBloc extends Bloc<ShelterEvent, ShelterState> {
  ShelterBloc({required ShelterRepository shelterRepository})
      : _shelterRepository = shelterRepository,
        super(const ShelterState()) {
    on<ShelterFetched>(
      _onShelterFetched,
      transformer: shelterThrottleDroppable(shelterThrottleDuration),
    );
    on<ShelterRefreshed>(
      _onShelterRefreshed,
      transformer: shelterThrottleDroppable(shelterCooldownDuration),
    );
    on<ShelterSearched>(
      _onShelterSearched,
    );
    on<ShelterClearSearched>(
      _onShelterClearSearched,
    );
  }

  final ShelterRepository _shelterRepository;

  Future<void> _onShelterFetched(
      ShelterFetched event, Emitter<ShelterState> emit) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == ShelterStatus.initial ||
          state.status == ShelterStatus.refresh) {
        final response =
            await _shelterRepository.getShelters(perPage: shelterLimit);

        if (response.shelters!.isEmpty) {
          return emit(state.copyWith(status: ShelterStatus.empty));
        }

        shelterCursor = response.meta['next_cursor'];

        return emit(
          state.copyWith(
            status: ShelterStatus.success,
            shelters: response.shelters,
            hasReachedMax: shelterCursor == null,
          ),
        );
      }

      final response = await _shelterRepository.getShelters(
          perPage: shelterLimit, cursor: shelterCursor, refresh: true);

      shelterCursor = response.meta['next_cursor'];

      if (response.shelters?.isNotEmpty ?? false) {
        emit(
          state.copyWith(
            status: ShelterStatus.success,
            shelters: response.shelters,
            hasReachedMax: shelterCursor == null,
          ),
        );
      } else {
        emit(state.copyWith(hasReachedMax: true));
      }
    } catch (_) {
      emit(state.copyWith(status: ShelterStatus.failure));
    }
  }

  Future<void> _onShelterRefreshed(
      ShelterRefreshed event, Emitter<ShelterState> emit) async {
    shelterCursor = null;

    _shelterRepository.clearCachedShelters();

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

  Future<void> _onShelterSearched(
      ShelterSearched event, Emitter<ShelterState> emit) async {
    final query = event.query.toLowerCase();

    try {
      final response = await _shelterRepository.searchShelters(
          perPage: shelterLimit, cursor: shelterFilterCursor, query: query);

      if (response.shelters!.isEmpty) {
        return emit(state.copyWith(status: ShelterStatus.notFound));
      }

      shelterFilterCursor = response.meta['next_cursor'];

      emit(
        state.copyWith(
          status: ShelterStatus.success,
          filteredShelters: response.shelters,
          hasReachedMax: shelterFilterCursor == null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ShelterStatus.failure));
    }
  }

  Future<void> _onShelterClearSearched(
      ShelterClearSearched event, Emitter<ShelterState> emit) async {
    shelterFilterCursor = null;

    emit(
      state.copyWith(
        status: ShelterStatus.success,
        filteredShelters: [],
        hasReachedMax: shelterCursor == null,
      ),
    );
  }
}
