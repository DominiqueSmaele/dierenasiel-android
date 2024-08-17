import 'dart:async';

import 'package:dierenasiel_android/shelters/bloc/shelter_animal/shelter_animal_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shelter_repository/shelter_repository.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/animals/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShelterDetail extends StatefulWidget {
  const ShelterDetail({required this.shelter, super.key});

  final Shelter shelter;

  @override
  State<ShelterDetail> createState() => ShelterDetailState();
}

class ShelterDetailState extends State<ShelterDetail> {
  final Completer<GoogleMapController> _controller = Completer();
  final _scrollController = ScrollController();
  final _debounceDuration = const Duration(milliseconds: 300);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
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

  int? selectedType;

  Timer? _debounce;
  late String _mapStyleString;

  late final CameraPosition _location = CameraPosition(
    target: LatLng(widget.shelter.address!.coordinates.latitude,
        widget.shelter.address!.coordinates.longitude),
    zoom: 15,
  );

  late final Marker _marker = Marker(
    markerId: const MarkerId('shelter_marker'),
    position: LatLng(widget.shelter.address!.coordinates.latitude,
        widget.shelter.address!.coordinates.longitude),
    infoWindow: InfoWindow(
      title: widget.shelter.name,
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(258),
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onTextChanged);

    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    String shelterImageUrl;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double screenHeight = MediaQuery.of(context).size.height;

    if (widget.shelter.image == null) {
      shelterImageUrl =
          '${dotenv.env['WEB']}/storage/images/shelter/logo-placeholder.png';
    } else {
      shelterImageUrl = widget.shelter.image!.original.url;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          //controller: _scrollController,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.fitHeight,
                          height: 150.0,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 15.0),
                        Text(
                          widget.shelter.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 32.0),
                    child: Column(
                      children: [
                        _ShelterDetails(shelter: widget.shelter),
                        const SizedBox(height: 16.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: GoogleMap(
                              initialCameraPosition: _location,
                              gestureRecognizers: const {
                                Factory<OneSequenceGestureRecognizer>(
                                    EagerGestureRecognizer.new),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
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
                              children:
                                  widget.shelter.openingPeriods!.isNotEmpty
                                      ? widget.shelter.openingPeriods!
                                          .map((openingPeriod) {
                                          final closed =
                                              openingPeriod.open == null &&
                                                  openingPeriod.close == null;

                                          return Card(
                                            margin: const EdgeInsets.only(
                                                top: 5.0, bottom: 15.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            color: primaryColor,
                                            child: ListTile(
                                              trailing: Text(
                                                !closed
                                                    ? '${_timeFormat.format(openingPeriod.open!)} - ${_timeFormat.format(openingPeriod.close!)}'
                                                    : 'Gesloten',
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
                                      : [
                                          Container(
                                            margin: const EdgeInsets.all(32),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32.0,
                                                vertical: 64.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
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
                        const SizedBox(height: 25.0),
                        const Divider(
                          color: primaryColor,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                        const SizedBox(height: 25.0),
                        BlocBuilder<ShelterAnimalBloc, ShelterAnimalState>(
                          builder: (context, state) {
                            switch (state.status) {
                              case ShelterAnimalStatus.failure:
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0),
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/empty.svg',
                                                height: 125,
                                                color: primaryColor,
                                              ),
                                              const SizedBox(height: 8.0),
                                              const Text(
                                                'Het ophalen van dieren is mislukt...',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              case ShelterAnimalStatus.empty:
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints
                                              .maxHeight, // Ensure it fills the screen height
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0),
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/empty.svg',
                                                height: 125,
                                                color: primaryColor,
                                              ),
                                              const SizedBox(height: 8.0),
                                              const Text(
                                                'Oops, geen dieren gevonden in dit dierenasiel!',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              case ShelterAnimalStatus.notFound:
                                return Column(
                                  children: [
                                    SearchBar(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      padding: const WidgetStatePropertyAll<
                                          EdgeInsets>(
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                      ),
                                      leading: const Icon(
                                        Icons.search,
                                        color: primaryColor,
                                      ),
                                      hintText: 'Zoeken',
                                      onChanged: _onSearchChanged,
                                      trailing:
                                          _searchController.text.isNotEmpty
                                              ? [
                                                  IconButton(
                                                    onPressed: _clearSearch,
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ]
                                              : null,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: state.types.length,
                                              itemBuilder: (context, index) {
                                                final type = state.types[index];
                                                final isSelected =
                                                    selectedType == type.id;
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (isSelected) {
                                                      setState(() {
                                                        selectedType = null;
                                                      });
                                                      context
                                                          .read<
                                                              ShelterAnimalBloc>()
                                                          .add(
                                                              const ShelterAnimalTypeSelected(
                                                                  null));
                                                    } else {
                                                      setState(() {
                                                        selectedType = type.id;
                                                      });
                                                      context
                                                          .read<
                                                              ShelterAnimalBloc>()
                                                          .add(
                                                              ShelterAnimalTypeSelected(
                                                                  type.id));
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Chip(
                                                      label: Text(
                                                        type.name,
                                                        style: TextStyle(
                                                          color: isSelected
                                                              ? white
                                                              : primaryColor,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          isSelected
                                                              ? primaryColor
                                                              : white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        side: BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32.0, vertical: 128),
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/empty.svg',
                                            height: 125,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(height: 8.0),
                                          const Text(
                                            'Oops, Geen dierenasielen gevonden!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              case ShelterAnimalStatus.success:
                                final displayAnimals =
                                    state.filteredAnimals.isNotEmpty
                                        ? state.filteredAnimals
                                        : state.searchedAnimals.isNotEmpty
                                            ? state.searchedAnimals
                                            : state.animals;

                                return Column(
                                  children: [
                                    SearchBar(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      padding: const WidgetStatePropertyAll<
                                          EdgeInsets>(
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                      ),
                                      leading: const Icon(
                                        Icons.search,
                                        color: primaryColor,
                                      ),
                                      hintText: 'Zoeken',
                                      onChanged: _onSearchChanged,
                                      trailing:
                                          _searchController.text.isNotEmpty
                                              ? [
                                                  IconButton(
                                                    onPressed: _clearSearch,
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ]
                                              : null,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: state.types.length,
                                              itemBuilder: (context, index) {
                                                final type = state.types[index];
                                                final isSelected =
                                                    selectedType == type.id;
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (isSelected) {
                                                      setState(() {
                                                        selectedType = null;
                                                      });
                                                      context
                                                          .read<
                                                              ShelterAnimalBloc>()
                                                          .add(
                                                              const ShelterAnimalTypeSelected(
                                                                  null));
                                                    } else {
                                                      setState(() {
                                                        selectedType = type.id;
                                                      });
                                                      context
                                                          .read<
                                                              ShelterAnimalBloc>()
                                                          .add(
                                                              ShelterAnimalTypeSelected(
                                                                  type.id));
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Chip(
                                                      label: Text(
                                                        type.name,
                                                        style: TextStyle(
                                                          color: isSelected
                                                              ? white
                                                              : primaryColor,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          isSelected
                                                              ? primaryColor
                                                              : white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        side: BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GridView.builder(
                                      padding:
                                          const EdgeInsets.only(bottom: 32.0),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16.0,
                                        mainAxisSpacing: 16.0,
                                        mainAxisExtent: screenHeight * 0.3,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return index >= displayAnimals.length
                                            ? const BottomLoader()
                                            : AnimalListItem(
                                                animal: displayAnimals[index]);
                                      },
                                      itemCount: state.hasReachedMax
                                          ? displayAnimals.length
                                          : displayAnimals.length + 1,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                    )
                                  ],
                                );
                              case ShelterAnimalStatus.initial:
                                return const Center(
                                    child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ShelterAnimalBloc>().add(ShelterAnimalFetched());
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(_debounceDuration, () {
      if (query.isEmpty) {
        context.read<ShelterAnimalBloc>().add(ShelterAnimalClearSearched());
      } else {
        context.read<ShelterAnimalBloc>().add(ShelterAnimalSearched(query));
      }
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
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
            phoneNumberType: shelter.phone.startsWith('+324')
                ? PhoneNumberType.mobile
                : PhoneNumberType.fixedLine,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        _ShelterInfoField(
          icon: Icons.location_on,
          label: 'Adres',
          value:
              '${shelter.address!.street} ${shelter.address!.number}, ${shelter.address!.zipcode} ${shelter.address!.city}',
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
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
