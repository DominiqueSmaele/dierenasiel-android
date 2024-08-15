import 'package:equatable/equatable.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:shelter_repository/src/models/models.dart';
import 'package:type_repository/src/models/models.dart';
import 'package:quality_repository/src/models/models.dart';

final class Animal extends Equatable {
  const Animal({
    required this.id,
    required this.name,
    required this.sex,
    this.birthDate,
    this.race,
    required this.description,
    required this.image,
    required this.qualities,
    required this.type,
    required this.shelter,
  });

  final int id;
  final String name;
  final String sex;
  final DateTime? birthDate;
  final String? race;
  final String description;
  final Media image;
  final List<Quality> qualities;
  final Type type;
  final Shelter shelter;

  @override
  List<Object?> get props => [id, name, sex, birthDate, race, description, image, qualities, type, shelter];
}