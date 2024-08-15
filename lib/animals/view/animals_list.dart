import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:dierenasiel_android/animals/animals.dart';
import 'package:dierenasiel_android/animals/widgets/widgets.dart';

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<AnimalBloc, AnimalState>(
                builder: (context, state) {
                  switch (state.status) {
                    case AnimalStatus.failure:
                      return const Center(child: Text('Het ophalen van dieren is mislukt...'));
                    case AnimalStatus.notFound:
                      return const Center(child: Text('Geen dieren gevonden...'));
                    case AnimalStatus.success:
                      final displayAnimals = state.filteredAnimals.isNotEmpty
                          ? state.filteredAnimals
                          : state.animals;

                      if (displayAnimals.isEmpty) {
                        return const Center(child: Text('Geen dieren gevonden...'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          mainAxisExtent: screenHeight * 0.3
                        ),
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
        ],
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
    if (_isBottom) context.read<AnimalBloc>().add(AnimalFetched());
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(_debounceDuration, () {
      if (query.isEmpty) {
        context.read<AnimalBloc>().add(AnimalClearSearched());
      } else {
        context.read<AnimalBloc>().add(AnimalSearched(query));
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
    return currentScroll >= (maxScroll * 0.6);
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    context.read<AnimalBloc>().add(AnimalRefreshed());
  }
}