import 'package:equatable/equatable.dart';
import '../../models/deal.dart';

// ─── Favorites Events ────────────────────────────
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesFetchRequested extends FavoritesEvent {}

class FavoritesSaveRequested extends FavoritesEvent {
  final Deal deal;

  const FavoritesSaveRequested(this.deal);

  @override
  List<Object?> get props => [deal.id];
}

class FavoritesRemoveRequested extends FavoritesEvent {
  final String dealId;

  const FavoritesRemoveRequested(this.dealId);

  @override
  List<Object?> get props => [dealId];
}

// ─── Favorites States ────────────────────────────
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Deal> deals;

  const FavoritesLoaded(this.deals);

  @override
  List<Object?> get props => [deals.length];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
