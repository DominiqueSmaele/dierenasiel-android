import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shelter_repository/shelter_repository.dart';

part 'shelter_timeslot_event.dart';
part 'shelter_timeslot_state.dart';

class ShelterTimeslotBloc
    extends Bloc<ShelterTimeslotEvent, ShelterTimeslotState> {
  ShelterTimeslotBloc({required ShelterRepository shelterRepository})
      : _shelterRepository = shelterRepository,
        super(const ShelterTimeslotState()) {
    on<ShelterTimeslotFetched>(
      _onShelterTimeSlotFetched,
    );
  }

  final ShelterRepository _shelterRepository;

  Future<void> _onShelterTimeSlotFetched(
      ShelterTimeslotFetched event, Emitter<ShelterTimeslotState> emit) async {
    try {
      if (state.status == ShelterTimeslotStatus.initial) {
        final response = await _shelterRepository.getSheltersTimeslots();

        if (response.shelters!.isEmpty) {
          return emit(state.copyWith(status: ShelterTimeslotStatus.failure));
        }

        return emit(
          state.copyWith(
            status: ShelterTimeslotStatus.success,
            shelters: response.shelters,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: ShelterTimeslotStatus.failure));
    }
  }
}
