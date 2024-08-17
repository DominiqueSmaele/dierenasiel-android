import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'timeslots_event.dart';
part 'timeslots_state.dart';

const timeslotThrottleDuration = Duration(milliseconds: 100);
const timeslotCooldownDuration = Duration(seconds: 5);
const refreshDelay = Duration(milliseconds: 500);

EventTransformer<E> shelterThrottleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class TimeslotBloc extends Bloc<TimeslotEvent, TimeslotState> {
  TimeslotBloc({required TimeslotRepository timeslotRepository})
      : _timeslotRepository = timeslotRepository,
        super(const TimeslotState()) {
    on<TimeslotFetched>(
      _onTimeSlotFetched,
      transformer: shelterThrottleDroppable(timeslotThrottleDuration),
    );
    on<TimeslotRefreshed>(
      _onTimeSlotRefreshed,
      transformer: shelterThrottleDroppable(timeslotCooldownDuration),
    );
    on<TimeslotUserDelete>(
      _onTimeSlotUserDelete,
    );
  }

  final TimeslotRepository _timeslotRepository;

  Future<void> _onTimeSlotFetched(
      TimeslotFetched event, Emitter<TimeslotState> emit) async {
    try {
      if (state.status == TimeslotStatus.initial ||
          state.status == TimeslotStatus.refresh) {
        final response = await _timeslotRepository.getUserTimeslots();

        if (response.timeslots!.isEmpty) {
          return emit(state.copyWith(status: TimeslotStatus.empty));
        }

        return emit(
          state.copyWith(
            status: TimeslotStatus.success,
            timeslots: response.timeslots,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: TimeslotStatus.failure));
    }
  }

  Future<void> _onTimeSlotUserDelete(
      TimeslotUserDelete event, Emitter<TimeslotState> emit) async {
    try {
      await _timeslotRepository.deleteTimeslotUser(id: event.timeslot.id);

      final updatedTimeslots = List<Timeslot>.from(state.timeslots)
        ..remove(event.timeslot);

      if (updatedTimeslots.isEmpty) {
        return emit(state.copyWith(status: TimeslotStatus.empty));
      }

      emit(
        state.copyWith(
          status: TimeslotStatus.success,
          timeslots: updatedTimeslots,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: TimeslotStatus.failure));
    }
  }

  Future<void> _onTimeSlotRefreshed(
      TimeslotRefreshed event, Emitter<TimeslotState> emit) async {
    emit(
      state.copyWith(
        status: TimeslotStatus.refresh,
        timeslots: [],
      ),
    );

    await Future.delayed(refreshDelay);

    add(TimeslotFetched());
  }
}
