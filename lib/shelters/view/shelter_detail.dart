import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';

class ShelterDetail extends StatefulWidget {
  const ShelterDetail({required this.shelter, super.key});

  final Shelter shelter;

  @override
  State<ShelterDetail> createState() => ShelterDetailState();
}

class ShelterDetailState extends State<ShelterDetail> {
  final Completer<GoogleMapController> _controller = Completer();
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final Map<int, String> dayNames = {
    1: 'Maandag',
    2: 'Dinsdag',
    3: 'Woesndag',
    4: 'Donderdag',
    5: 'Vrijdag',
    6: 'Zaterdag',
    7: 'Zondag',
  };

  late String _mapStyleString;

  late final CameraPosition _location = CameraPosition(
    target: LatLng(widget.shelter.address.coordinates.latitude, widget.shelter.address.coordinates.longitude),
    zoom: 15,
  );

  late final Marker _marker = Marker(
    markerId: const MarkerId('shelter_marker'),
    position: LatLng(widget.shelter.address.coordinates.latitude, widget.shelter.address.coordinates.longitude),
    infoWindow: InfoWindow(
      title: widget.shelter.name,
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(258),
  );

  @override
  void initState() {
    super.initState();

   rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
  });
  }

  @override
  Widget build(BuildContext context) { 
    String shelterImageUrl;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    if (widget.shelter.image == null) {
      shelterImageUrl = '${dotenv.env['WEB']}/storage/images/shelter/logo-placeholder.png';
    } else {
      shelterImageUrl = widget.shelter.image!.original.url;
    }
    
    return Material(
      color: backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32.0, 84.0, 32.0, 24.0),
                      decoration: const BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          imageUrl: shelterImageUrl,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          fit: BoxFit.fitHeight,
                          height: 150.0,
                          width: double.infinity,
                        ), 
                        const SizedBox(height: 15.0),
                        Flexible(
                          child: Text(
                            widget.shelter.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                children: [
                  _ShelterDetails(shelter: widget.shelter),
                  const SizedBox(height: 16.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: _location,
                        gestureRecognizers: const { 
                          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new), 
                        },
                        markers: {_marker},
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          _controller.future.then((value) {
                            value.setMapStyle(_mapStyleString);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero, 
                        childrenPadding: EdgeInsets.zero,
                        title: const Text(
                          'Openingsuren',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        iconColor: primaryColor, 
                        collapsedIconColor: primaryColor, 
                        initiallyExpanded: false, 
                        children: widget.shelter.openingPeriods!.isNotEmpty
                          ? widget.shelter.openingPeriods!.map((openingPeriod) {
                          final closed = openingPeriod.open == null && openingPeriod.close == null;

                          return Card(
                            margin: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Match the container's border radius
                            ),
                            color: primaryColor,
                            child: ListTile(
                              trailing: Text(
                                !closed ? '${_timeFormat.format(openingPeriod.open!)} - ${_timeFormat.format(openingPeriod.close!)}' :  'Gesloten',
                                style: const TextStyle(
                                  color: white,
                                  fontSize: 16.0,
                                ),
                              ),
                              title: Text(
                                dayNames[openingPeriod.day]!,
                                style: const TextStyle(
                                  color: white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          );
                        }).toList()
                    : [ Container(
                          margin: const EdgeInsets.all(32),
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0), 
                            color: primaryColor,
                          ),
                          child: const Text(
                            'Geen openingsuren aanwezig',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ), 
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelterDetails extends StatelessWidget {
  const _ShelterDetails({required this.shelter});

  final Shelter shelter;

  @override
  Widget build(BuildContext context) {
  final belgiumCountryCode = CountryWithPhoneCode(
    phoneCode: '32',
    countryCode: 'BE',
    exampleNumberMobileNational: '0485 49 87 76',
    exampleNumberFixedLineNational: '09 252 40 76',
    phoneMaskMobileNational: '+00 0000 00 00 00',
    phoneMaskFixedLineNational: '+00 00 000 00 00',
    exampleNumberMobileInternational: '+32 485 49 87 76',
    exampleNumberFixedLineInternational: '+32 9 252 40 76',
    phoneMaskMobileInternational: '+00 000 00 00 00',
    phoneMaskFixedLineInternational: '+00 0 000 00 00',
    countryName: 'Belgium',
  );
  
    return Column(
      children: [
        _ShelterInfoField(
          icon: Icons.email,
          label: 'E-mailadres',
          value: shelter.email,
        ),
        const Padding(padding: EdgeInsets.all(8)),
        _ShelterInfoField(
          icon: Icons.phone,
          label: 'Telefoonnummer',
          value: formatNumberSync(
            shelter.phone,
            country: belgiumCountryCode,
            phoneNumberType: shelter.phone.startsWith('04') ? PhoneNumberType.mobile : PhoneNumberType.fixedLine,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        _ShelterInfoField(
          icon: Icons.location_on,
          label: 'Adres',
          value: '${shelter.address.street} ${shelter.address.number}, ${shelter.address.zipcode} ${shelter.address.city}',
        ),
      ],
    );
  }
}


class _ShelterInfoField extends StatelessWidget {
  const _ShelterInfoField({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  final IconData icon;
  final String label;
  final String value;
  

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        label,
        style: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value,
      ),
      tileColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), 
    );
  }
}

