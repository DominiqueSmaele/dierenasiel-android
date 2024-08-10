import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnimalListItem extends StatelessWidget {
  const AnimalListItem({required this.animal, super.key});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(animal.image.original.url);
    final imageUrl = '${dotenv.env['WEB']}${uri.path.substring(uri.path.indexOf('/storage'))}';

  return ClipRRect(
    borderRadius: BorderRadius.circular(16.0), // Apply rounded corners to the container
    child: Container(
      color: white, // Background color for the container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            height: 175.0,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  animal.name,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    animal.sex == 'm' ? Icons.male : Icons.female,
                    color: animal.sex == 'm' ? Colors.blue : Colors.pink[300],
                    size: 21.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              animal.race ?? '-',
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}