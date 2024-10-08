import 'package:flutter/material.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:quality_repository/quality_repository.dart';
import 'package:string_capitalize/string_capitalize.dart';

class ShelterAnimalDetail extends StatelessWidget {
  const ShelterAnimalDetail({required this.animal, super.key});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    final List<Quality> sortedAnimalQualities = List.from(animal.qualities);
    sortedAnimalQualities.sort((a, b) => a.name.compareTo(b.name));

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: animal.image.original.url,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            height: screenHeight * 0.6,
            width: double.infinity,
          ),
          Positioned(
            top: statusBarHeight + 16.0,
            left: 24.0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: primaryColor,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          animal.race ?? 'Onbekend ras',
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: textColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    animal.sex == 'm'
                                        ? Icons.male
                                        : Icons.female,
                                    color:
                                        animal.sex == 'm' ? Colors.blue : pink,
                                    size: 21.0,
                                  ),
                                  const SizedBox(width: 2.5),
                                  Text(
                                    animal.sex == 'm'
                                        ? 'Mannelijk'
                                        : 'Vrouwelijk',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: primaryColor,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _calculateAge(animal.birthDate) ??
                                        'Onbekende leeftijd',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          animal.description,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              title: const Text(
                                'Eigenschappen',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              iconColor: primaryColor,
                              collapsedIconColor: primaryColor,
                              initiallyExpanded: false,
                              children: sortedAnimalQualities.map((quality) {
                                return Card(
                                  margin: const EdgeInsets.only(
                                      top: 5.0, bottom: 15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  color: primaryColor,
                                  child: ListTile(
                                    trailing: Icon(
                                      size: 28.0,
                                      quality.value == null
                                          ? Icons.help
                                          : quality.value!
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                      color: quality.value == null
                                          ? orange
                                          : quality.value!
                                              ? green
                                              : lightDarkRed,
                                    ),
                                    title: Text(
                                      quality.name.capitalize(),
                                      style: const TextStyle(
                                        color: white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;

    try {
      DateTime now = DateTime.now();

      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;

      if (months < 0) {
        years--;
        months += 12;
      }

      if (now.day < birthDate.day) {
        if (months == 0) {
          years--;
          months = 11;
        } else {
          months--;
        }
      }

      return '$years jaar en $months maand';
    } catch (e) {
      rethrow;
    }
  }
}
