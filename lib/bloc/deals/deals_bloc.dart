import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/deal_service.dart';
import 'deals_event.dart';

// Re-export event and state for convenience
export 'deals_event.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState> {
  final DealService _dealService;

  DealsBloc({required DealService dealService})
      : _dealService = dealService,
        super(DealsInitial()) {
    on<DealsFetchTrending>(_onFetchTrending);
    on<DealsSearchRequested>(_onSearchRequested);
    on<DealsImageSearchRequested>(_onImageSearch);
  }

  Future<void> _onFetchTrending(
    DealsFetchTrending event,
    Emitter<DealsState> emit,
  ) async {
    emit(DealsLoading());
    try {
      final result = await _dealService.getTrending();
      emit(DealsLoaded(result));
    } catch (e) {
      emit(DealsError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    DealsSearchRequested event,
    Emitter<DealsState> emit,
  ) async {
    emit(DealsLoading());
    try {
      final result = await _dealService.search(
        query: event.query,
        sort: event.sort,
      );
      emit(DealsLoaded(result));
    } catch (e) {
      emit(DealsError(e.toString()));
    }
  }

  Future<void> _onImageSearch(
    DealsImageSearchRequested event,
    Emitter<DealsState> emit,
  ) async {
    emit(DealsLoading());
    try {
      final result = await _dealService.imageSearch(File(event.imagePath));
      emit(DealsLoaded(result));
    } catch (e) {
      emit(DealsError(e.toString()));
    }
  }
}
