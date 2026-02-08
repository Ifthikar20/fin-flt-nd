import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/alert_service.dart';
import 'alerts_event.dart';

// Re-export for convenience
export 'alerts_event.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final AlertService _alertService;

  AlertsBloc({required AlertService alertService})
      : _alertService = alertService,
        super(AlertsInitial()) {
    on<AlertsFetchRequested>(_onFetch);
    on<AlertsCreateRequested>(_onCreate);
    on<AlertsDeleteRequested>(_onDelete);
  }

  Future<void> _onFetch(
    AlertsFetchRequested event,
    Emitter<AlertsState> emit,
  ) async {
    emit(AlertsLoading());
    try {
      final alerts = await _alertService.getAlerts();
      emit(AlertsLoaded(alerts));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> _onCreate(
    AlertsCreateRequested event,
    Emitter<AlertsState> emit,
  ) async {
    try {
      await _alertService.createAlert(
        productQuery: event.productQuery,
        productName: event.productName,
        targetPrice: event.targetPrice,
        originalPrice: event.originalPrice,
        productImage: event.productImage,
      );
      add(AlertsFetchRequested());
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    AlertsDeleteRequested event,
    Emitter<AlertsState> emit,
  ) async {
    try {
      await _alertService.deleteAlert(event.alertId);
      add(AlertsFetchRequested());
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
}
