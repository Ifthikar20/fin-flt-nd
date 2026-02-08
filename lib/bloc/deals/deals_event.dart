import 'package:equatable/equatable.dart';
import '../../models/deal.dart';

// ─── Deals Events ────────────────────────────────
abstract class DealsEvent extends Equatable {
  const DealsEvent();

  @override
  List<Object?> get props => [];
}

class DealsFetchTrending extends DealsEvent {}

class DealsSearchRequested extends DealsEvent {
  final String query;
  final String sort;

  const DealsSearchRequested({required this.query, this.sort = 'relevance'});

  @override
  List<Object?> get props => [query, sort];
}

class DealsImageSearchRequested extends DealsEvent {
  final String imagePath;

  const DealsImageSearchRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

// ─── Deals States ────────────────────────────────
abstract class DealsState extends Equatable {
  const DealsState();

  @override
  List<Object?> get props => [];
}

class DealsInitial extends DealsState {}

class DealsLoading extends DealsState {}

class DealsLoaded extends DealsState {
  final SearchResult result;

  const DealsLoaded(this.result);

  @override
  List<Object?> get props => [result.total, result.query];
}

class DealsError extends DealsState {
  final String message;

  const DealsError(this.message);

  @override
  List<Object?> get props => [message];
}
