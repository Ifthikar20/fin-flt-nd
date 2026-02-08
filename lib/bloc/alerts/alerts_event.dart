import 'package:equatable/equatable.dart';
import '../../models/price_alert.dart';

// ─── Alerts Events ───────────────────────────────
abstract class AlertsEvent extends Equatable {
  const AlertsEvent();

  @override
  List<Object?> get props => [];
}

class AlertsFetchRequested extends AlertsEvent {}

class AlertsCreateRequested extends AlertsEvent {
  final String productQuery;
  final String productName;
  final double targetPrice;
  final double? originalPrice;
  final String? productImage;

  const AlertsCreateRequested({
    required this.productQuery,
    required this.productName,
    required this.targetPrice,
    this.originalPrice,
    this.productImage,
  });

  @override
  List<Object?> get props => [productQuery, targetPrice];
}

class AlertsDeleteRequested extends AlertsEvent {
  final String alertId;

  const AlertsDeleteRequested(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

// ─── Alerts States ───────────────────────────────
abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<PriceAlert> alerts;

  const AlertsLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts.length];
}

class AlertsError extends AlertsState {
  final String message;

  const AlertsError(this.message);

  @override
  List<Object?> get props => [message];
}
