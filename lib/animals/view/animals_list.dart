import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/animals/animals.dart';
import 'package:dierenasiel_android/animals/widgets/widgets.dart';

class AnimalsList extends StatefulWidget {
  const AnimalsList({super.key});

  @override
  State<AnimalsList> createState() => AnimalsListState();
}

class AnimalsListState extends State<AnimalsList> {
  final _scrollController = ScrollController();
  final _debounceDuration = const Duration(milliseconds: 300);
  Timer? _debounce;

 final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

@override
Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
            child: SearchBar(
              focusNode: _searchFocusNode, // Attach the focus node
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              leading: const Icon(Icons.search),
              hintText: 'Zoeken',
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<AnimalBloc, AnimalState>(
                builder: (context, state) {
                  switch (state.status) {
                    case AnimalStatus.failure:
                      return const Center(child: Text('Failed to fetch animals...'));
                    case AnimalStatus.success:
                      final displayAnimals = state.filteredAnimals.isNotEmpty
                          ? state.filteredAnimals
                          : state.animals;

                      if (displayAnimals.isEmpty) {
                        return const Center(child: Text('No animals found'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.7,
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
                      );
                    case AnimalStatus.initial:
                      return const Center(child: CircularProgressIndicator());
                    case AnimalStatus.loading:
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
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<AnimalBloc>().add(AnimalFetched());
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(_debounceDuration, () {
      if (query.isEmpty) {
        // If the query is empty, show all animals
        context.read<AnimalBloc>().add(AnimalClearSearched());
      } else {
        // Trigger search with the current query
        context.read<AnimalBloc>().add(AnimalSearched(query));
      }
    });
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    context.read<AnimalBloc>().add(AnimalRefreshed());
  }
}