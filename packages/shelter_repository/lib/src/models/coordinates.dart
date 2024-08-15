import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude];
}