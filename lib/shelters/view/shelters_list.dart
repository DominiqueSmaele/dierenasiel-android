import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/helper/constants.dart';
import 'package:dierenasiel_android/shelters/shelters.dart';
import 'package:dierenasiel_android/shelters/widgets/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


class SheltersList extends StatefulWidget {
  const SheltersList({super.key});

  @override
  State<SheltersList> createState() => SheltersListState();
}

class SheltersListState extends State<SheltersList> {
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
              child: BlocBuilder<ShelterBloc, ShelterState>(
                builder: (context, state) {
                  switch (state.status) {
                    case ShelterStatus.failure:
                      return const Center(child: Text('Het ophalen van dierenasielen is mislukt...'));
                    case ShelterStatus.notFound:
                      return const Center(child: Text('Geen dierenasielen gevonden...'));
                    case ShelterStatus.success:
                      final displayShelters = state.filteredShelters.isNotEmpty
                        ? state.filteredShelters
                        : state.shelters;

                      if (displayShelters.isEmpty) {
                        return const Center(child: Text('Geen dierenasielen gevonden...'));
                      }

                      return MasonryGridView.count(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        itemBuilder: (BuildContext context, int index) {
                          return index >= displayShelters.length
                            ? const BottomLoader()
                            : ShelterListItem(shelter: displayShelters[index]);
                        },
                        itemCount: state.hasReachedMax
                          ? displayShelters.length
                          : displayShelters.length + 1,
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                      );
                    case ShelterStatus.initial:
                      return const Center(child: CircularProgressIndicator());
                    case ShelterStatus.refresh:
                      return const Center(child: CircularProgressIndicator());
                  }
                }
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
    if (_isBottom) context.read<ShelterBloc>().add(ShelterFetched());
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(_debounceDuration, () {
      if (query.isEmpty) {
        // If the query is empty, show all animals
        context.read<ShelterBloc>().add(ShelterClearSearched());
      } else {
        // Trigger search with the current query
        context.read<ShelterBloc>().add(ShelterSearched(query));
      }
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged(''); // Clear search results if necessary
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    context.read<ShelterBloc>().add(ShelterRefreshed());
  }
}