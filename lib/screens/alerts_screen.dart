import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alerts/alerts_bloc.dart';
import '../bloc/alerts/alerts_event.dart';
import '../models/price_alert.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AlertsBloc>().add(AlertsFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AlertsBloc, AlertsState>(
        builder: (context, state) {
          if (state is AlertsLoading || state is AlertsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlertsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        context.read<AlertsBloc>().add(AlertsFetchRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AlertsLoaded) {
            if (state.alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 56, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    Text('No price alerts',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Set alerts on products and we\'ll notify\nyou when the price drops',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.alerts.length,
              itemBuilder: (_, i) => _AlertCard(
                alert: state.alerts[i],
                onDelete: () => context
                    .read<AlertsBloc>()
                    .add(AlertsDeleteRequested(state.alerts[i].id)),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final PriceAlert alert;
  final VoidCallback onDelete;

  const _AlertCard({required this.alert, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: alert.isTriggered ? AppTheme.success : AppTheme.border,
          width: alert.isTriggered ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          if (alert.productImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                alert.productImage!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.bgCardLight,
                  child: const Icon(Icons.image_outlined,
                      color: AppTheme.textMuted, size: 24),
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active,
                  color: AppTheme.textMuted),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Target: ${alert.formattedTarget}',
                      style: TextStyle(fontSize: 12, color: AppTheme.accent,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Now: ${alert.formattedCurrent}',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                if (alert.isTriggered) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '🎉 Price dropped!',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
