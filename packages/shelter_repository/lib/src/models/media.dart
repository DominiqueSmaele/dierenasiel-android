import 'package:equatable/equatable.dart';

final class Media extends Equatable {
  const Media({
    required this.original,
    this.conversions,
  });

  final Original original;
  final List<Conversion>? conversions;

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      original: Original.fromJson(json['original'] as Map<String, dynamic>),
      conversions: (json['conversions'] as List<dynamic>?)
          ?.map(
            (item) => Conversion.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [original, conversions];
}

class Original extends Equatable {
  const Original({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final int width;
  final int height;

  factory Original.fromJson(Map<String, dynamic> json) {
    return Original(
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  @override
  List<Object> get props => [url, width, height];
}

class Conversion extends Equatable {
  const Conversion({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final int width;
  final int height;

  factory Conversion.fromJson(Map<String, dynamic> json) {
    return Conversion(
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  @override
  List<Object> get props => [url, width, height];
}
