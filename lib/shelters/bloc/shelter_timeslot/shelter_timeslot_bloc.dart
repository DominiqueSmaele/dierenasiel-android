import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timeslot_repository/timeslot_repository.dart';
import 'package:shelter_repository/shelter_repository.dart';

part 'shelter_timeslot_event.dart';
part 'shelter_timeslot_state.dart';

class ShelterTimeslotBloc
    extends Bloc<ShelterTimeslotEvent, ShelterTimeslotState> {
  ShelterTimeslotBloc(
      {required ShelterRepository shelterRepository,
      required TimeslotRepository timeslotRepository})
      : _shelterRepository = shelterRepository,
        _timeslotRepository = timeslotRepository,
        super(const ShelterTimeslotState()) {
    on<ShelterTimeslotFetched>(
      _onShelterTimeSlotFetched,
    );
    on<ShelterTimeslotUserBook>(
      _onShelterTimeslotUserBook,
    );
  }

  final ShelterRepository _shelterRepository;
  final TimeslotRepository _timeslotRepository;

  Future<void> _onShelterTimeSlotFetched(
      ShelterTimeslotFetched event, Emitter<ShelterTimeslotState> emit) async {
    try {
      if (state.status == ShelterTimeslotStatus.initial) {
        final response = await _shelterRepository.getSheltersTimeslots();

        print(response);

        if (response.shelters!.isEmpty) {
          return emit(state.copyWith(status: ShelterTimeslotStatus.empty));
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

  Future<void> _onShelterTimeslotUserBook(
      ShelterTimeslotUserBook event, Emitter<ShelterTimeslotState> emit) async {
    try {
      await _timeslotRepository.bookTimeslotUser(id: event.timeslot.id);

      final shelterIndex = state.shelters
          .indexWhere((shelter) => shelter.id == event.shelter.id);

      final updatedTimeslots = List<Timeslot>.from(
          state.shelters[shelterIndex].timeslots as Iterable)
        ..removeWhere((timeslot) => timeslot.id == event.timeslot.id);

      final updatedShelters = List<Shelter>.from(state.shelters)
        ..[shelterIndex] =
            state.shelters[shelterIndex].copyWith(timeslots: updatedTimeslots);

      emit(
        state.copyWith(
          status: ShelterTimeslotStatus.success,
          shelters: updatedShelters,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ShelterTimeslotStatus.failure));
    }
  }
}
