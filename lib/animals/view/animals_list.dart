import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:dierenasiel_android/animals/animals.dart';
import 'package:dierenasiel_android/animals/widgets/widgets.dart';
import 'package:animal_repository/animal_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimalsList extends StatefulWidget {
  const AnimalsList({super.key});

  @override
  State<AnimalsList> createState() => AnimalsListState();
}

class AnimalsListState extends State<AnimalsList> {
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _debounceDuration = const Duration(milliseconds: 300);
  Timer? _debounce;

  int? selectedType;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          backgroundColor: white,
          color: primaryColor,
          child: BlocBuilder<AnimalBloc, AnimalState>(
            builder: (context, state) {
              switch (state.status) {
                case AnimalStatus.failure:
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                case AnimalStatus.empty:
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints
                                .maxHeight, // Ensure it fills the screen height
                          ),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/empty.svg',
                                  height: 125,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  'Oops, geen dieren gevonden!',
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
                case AnimalStatus.notFound:
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                        child: SearchBar(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          leading: const Icon(
                            Icons.search,
                            color: primaryColor,
                          ),
                          hintText: 'Zoeken',
                          onChanged: _onSearchChanged,
                          trailing: _searchController.text.isNotEmpty
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
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
                                    final isSelected = selectedType == type.id;
                                    return GestureDetector(
                                      onTap: () {
                                        if (isSelected) {
                                          setState(() {
                                            selectedType = null;
                                          });
                                          context.read<AnimalBloc>().add(
                                              const AnimalTypeSelected(null));
                                        } else {
                                          setState(() {
                                            selectedType = type.id;
                                          });
                                          context
                                              .read<AnimalBloc>()
                                              .add(AnimalTypeSelected(type.id));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
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
                                              isSelected ? primaryColor : white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/empty.svg',
                                height: 125,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Oops, Geen dieren gevonden!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                case AnimalStatus.success:
                  final displayAnimals = state.filteredAnimals.isNotEmpty
                      ? state.filteredAnimals
                      : state.searchedAnimals.isNotEmpty
                          ? state.searchedAnimals
                          : state.animals;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                        child: SearchBar(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          leading: const Icon(
                            Icons.search,
                            color: primaryColor,
                          ),
                          hintText: 'Zoeken',
                          onChanged: _onSearchChanged,
                          trailing: _searchController.text.isNotEmpty
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.types.length,
                                  itemBuilder: (context, index) {
                                    final type = state.types[index];
                                    final isSelected = selectedType == type.id;
                                    return GestureDetector(
                                      onTap: () {
                                        if (isSelected) {
                                          setState(() {
                                            selectedType = null;
                                          });
                                          context.read<AnimalBloc>().add(
                                              const AnimalTypeSelected(null));
                                        } else {
                                          setState(() {
                                            selectedType = type.id;
                                          });
                                          context
                                              .read<AnimalBloc>()
                                              .add(AnimalTypeSelected(type.id));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
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
                                              isSelected ? primaryColor : white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  mainAxisExtent: screenHeight * 0.3),
                          itemBuilder: (BuildContext context, int index) {
                            return index >= displayAnimals.length
                                ? const BottomLoader()
                                : AnimalListItem(animal: displayAnimals[index]);
                          },
                          itemCount: state.hasReachedMax
                              ? displayAnimals.length
                              : displayAnimals.length + 1,
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                        ),
                      ),
                    ],
                  );
                case AnimalStatus.initial:
                  return const Center(child: CircularProgressIndicator());
                case AnimalStatus.refresh:
                  return const Center(child: CircularProgressIndicator());
              }
            },
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<AnimalBloc>().add(AnimalFetched());
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      context.read<AnimalBloc>().add(AnimalClearSearched());
    } else {
      _debounce = Timer(_debounceDuration, () {
        context.read<AnimalBloc>().add(AnimalSearched(query));
      });
    }
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

  Future<void> _onRefresh() async {
    context.read<AnimalBloc>().add(AnimalRefreshed());
    _searchController.clear();
    selectedType = null;
  }
}
