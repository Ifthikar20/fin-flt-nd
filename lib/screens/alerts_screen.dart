import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_alert.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

final alertsListProvider =
    FutureProvider.autoDispose<List<PriceAlert>>((ref) async {
  return ref.read(alertServiceProvider).getAlerts();
});

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        automaticallyImplyLeading: false,
      ),
      body: alerts.when(
        data: (list) {
          if (list.isEmpty) {
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
            itemCount: list.length,
            itemBuilder: (_, i) => _AlertCard(
              alert: list[i],
              onDelete: () async {
                await ref.read(alertServiceProvider).deleteAlert(list[i].id);
                ref.invalidate(alertsListProvider);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(alertsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
          // Product image
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

          // Details
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Now: ${alert.formattedCurrent}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (alert.isTriggered) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '🎉 Price dropped!',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Delete
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
