import 'package:equatable/equatable.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:shelter_repository/src/models/models.dart';
import 'package:type_repository/src/models/models.dart';
import 'package:shelter_repository/src/models/media.dart';

class AnimalResponse extends Equatable {
  AnimalResponse({
    this.animals,
    required this.meta,
  });

  final List<Animal>? animals;
  final Map<String, dynamic> meta;

  factory AnimalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final animalsList = data.map((dynamic item) {
      final map = item as Map<String, dynamic>;

      return Animal(
        id: map['id'] as int,
        name: map['name'] as String,
        sex: map['sex'] as String,
        birthDate: map['birth_date'] as String?,
        race: map['race'] as String?,
        description: map['description'] as String,
        image: Media.fromJson(item['image'] as Map<String, dynamic>),
        type: Type.fromJson(item['type'] as Map<String, dynamic>),
        shelter: Shelter.fromJson(item['shelter'] as Map<String, dynamic>),
      );
    }).toList();

    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return AnimalResponse(
      animals: animalsList,
      meta: meta,
    ); 
  }

  @override
  List<Object?> get props => [animals, meta];
}