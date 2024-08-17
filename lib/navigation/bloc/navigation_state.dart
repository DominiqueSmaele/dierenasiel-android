part of 'navigation_bloc.dart';

final class NavigationState extends Equatable {
  const NavigationState({
    this.index = 0,
  });

  final int index;

  NavigationState copyWith({
    int? index,
  }) {
    return NavigationState(
      index: index ?? this.index,
    );
  }

  @override
  List<Object> get props => [index];
}
