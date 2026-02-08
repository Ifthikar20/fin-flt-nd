import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/price_alert.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

final storyboardListProvider =
    FutureProvider.autoDispose<List<Storyboard>>((ref) async {
  return ref.read(storyboardServiceProvider).getStoryboards();
});

class StoryboardScreen extends ConsumerWidget {
  const StoryboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyboards = ref.watch(storyboardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Storyboards'),
      ),
      body: storyboards.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dashboard_customize_rounded,
                      size: 56, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('No storyboards yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Create storyboards on the web and\nview them here',
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
            itemBuilder: (_, i) => _StoryboardCard(storyboard: list[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(storyboardListProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}

class _StoryboardCard extends StatelessWidget {
  final Storyboard storyboard;

  const _StoryboardCard({required this.storyboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.dashboard_rounded,
                color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storyboard.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (storyboard.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Created ${_formatDate(storyboard.createdAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (storyboard.shareUrl.isNotEmpty) {
                Share.share(storyboard.shareUrl);
              }
            },
            icon: const Icon(Icons.share_outlined,
                size: 20, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${dt.month}/${dt.day}/${dt.year}';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}
