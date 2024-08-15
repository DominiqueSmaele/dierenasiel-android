import 'package:flutter/material.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dierenasiel_android/animals/view/view.dart';

class AnimalListItem extends StatelessWidget {
  const AnimalListItem({required this.animal, super.key});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimalDetail(animal: animal),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0), 
        child: Container(
          color: white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: animal.image.original.url,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                height: screenHeight * 0.2,
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
                  animal.race ?? 'Onbekend ras',
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}