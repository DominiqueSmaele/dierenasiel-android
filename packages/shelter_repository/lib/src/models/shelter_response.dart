import 'package:equatable/equatable.dart';
import 'package:shelter_repository/shelter_repository.dart';

class ShelterResponse extends Equatable {
  ShelterResponse({
    this.shelters,
    required this.meta,
  });

  final List<Shelter>? shelters;
  final Map<String, dynamic> meta;

  factory ShelterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final sheltersList = data.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      return Shelter.fromJson(map);
    }).toList();

    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return ShelterResponse(
      shelters: sheltersList,
      meta: meta,
    );
  }

  ShelterResponse copyWith({
    List<Shelter>? shelters,
    Map<String, dynamic>? meta,
  }) {
    return ShelterResponse(
      shelters: shelters ?? this.shelters,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [shelters, meta];
}
