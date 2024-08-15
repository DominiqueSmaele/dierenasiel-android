import 'package:animal_repository/animal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShelterListItem extends StatelessWidget {
  const ShelterListItem({required this.shelter, super.key});

  final Shelter shelter;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    String shelterImageUrl;

    if (shelter.image == null) {
      shelterImageUrl = '${dotenv.env['WEB']}/storage/images/shelter/logo-placeholder.png';
    } else {
      shelterImageUrl = shelter.image!.original.url;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ShelterAnimalBloc(
                shelter: shelter,
                animalRepository: context.read<AnimalRepository>(),
              )..add(ShelterAnimalFetched()),
              child: ShelterDetail(shelter: shelter),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: const BoxDecoration(
          color: white,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: shelterImageUrl,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
              height: screenHeight * 0.125,
              width: screenWidth * 0.35,
            ),
            Padding (
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  shelter.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}