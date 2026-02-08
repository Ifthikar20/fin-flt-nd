import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/favorites_service.dart';
import 'favorites_event.dart';

// Re-export for convenience
export 'favorites_event.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesService _favoritesService;

  FavoritesBloc({required FavoritesService favoritesService})
      : _favoritesService = favoritesService,
        super(FavoritesInitial()) {
    on<FavoritesFetchRequested>(_onFetch);
    on<FavoritesSaveRequested>(_onSave);
    on<FavoritesRemoveRequested>(_onRemove);
  }

  Future<void> _onFetch(
    FavoritesFetchRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final deals = await _favoritesService.getFavorites();
      emit(FavoritesLoaded(deals));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onSave(
    FavoritesSaveRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesService.saveDeal(event.deal);
      // Refresh list after save
      add(FavoritesFetchRequested());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemove(
    FavoritesRemoveRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesService.removeDeal(event.dealId);
      // Refresh list after remove
      add(FavoritesFetchRequested());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
