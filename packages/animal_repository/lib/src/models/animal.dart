import 'package:equatable/equatable.dart';
import 'package:shelter_repository/src/models/models.dart';
import 'package:type_repository/src/models/models.dart';
import 'package:shelter_repository/src/models/media.dart';

final class Animal extends Equatable {
  const Animal({
    required this.id,
    required this.name,
    required this.sex,
    this.birthDate,
    this.race,
    required this.description,
    required this.image,
    required this.type,
    required this.shelter,
  });

  final int id;
  final String name;
  final String sex;
  final String? birthDate;
  final String? race;
  final String description;
  final Media image;
  final Type type;
  final Shelter shelter;


  @override
  List<Object?> get props => [id, name, sex, birthDate, race, description, image, type, shelter];
}