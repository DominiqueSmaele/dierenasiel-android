import 'package:equatable/equatable.dart';
import 'package:shelter_repository/src/models/country.dart';
import 'package:shelter_repository/src/models/coordinates.dart';

final class Address extends Equatable {
  const Address({
    required this.id,
    required this.coordinates,
    required this.street,
    required this.number,
    this.boxNumber,
    required this.zipcode,
    required this.city,
    required this.country,
  });

  final int id;
  final Coordinates coordinates;
  final String street;
  final String number;
  final String? boxNumber;
  final String zipcode;
  final String city;
  final Country country;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      coordinates:
          Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      street: json['street'] as String,
      number: json['number'] as String,
      boxNumber: json['box_number'] as String?,
      zipcode: json['zipcode'] as String,
      city: json['city'] as String,
      country: Country.fromJson(json['country'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props =>
      [id, street, number, boxNumber, zipcode, city, country];
}
