import 'package:equatable/equatable.dart';
import 'package:shelter_repository/src/models/address.dart';
import 'package:shelter_repository/src/models/media.dart';

final class Shelter extends Equatable {
  const Shelter({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.facebook,
    this.instagram,
    this.tiktok,
    required this.address,
    this.image,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? facebook;
  final String? instagram;
  final String? tiktok;
  final Address address;
  final Media? image;

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      tiktok: json['tiktok'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      image: json['image'] != null ? Media.fromJson(json['image'] as Map<String, dynamic>) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, facebook, instagram, tiktok, address, image];
}