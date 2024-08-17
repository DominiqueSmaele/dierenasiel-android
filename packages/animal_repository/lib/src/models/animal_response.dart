import 'package:equatable/equatable.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:shelter_repository/src/models/models.dart';
import 'package:type_repository/src/models/models.dart';
import 'package:quality_repository/src/models/models.dart';
import 'package:intl/intl.dart';

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

      final qualitiesList = (map['qualities'] as List<dynamic>)
          .map((dynamic quality) =>
              Quality.fromJson(quality as Map<String, dynamic>))
          .toList();

      return Animal(
        id: map['id'] as int,
        name: map['name'] as String,
        sex: map['sex'] as String,
        birthDate: _convertStringToDatetime(map['birth_date'] as String?),
        race: map['race'] as String?,
        description: map['description'] as String,
        image: Media.fromJson(item['image'] as Map<String, dynamic>),
        qualities: qualitiesList,
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

  static DateTime? _convertStringToDatetime(String? dateOfBirth) {
    if (dateOfBirth == null) {
      return null;
    }

    return DateFormat('yyyy-MM-dd').parse(dateOfBirth);
  }

  AnimalResponse copyWith({
    List<Animal>? animals,
    Map<String, dynamic>? meta,
  }) {
    return AnimalResponse(
      animals: animals ?? this.animals,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [animals, meta];
}
