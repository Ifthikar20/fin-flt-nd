import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/price_alert.dart';
import '../services/api_client.dart';
import '../services/storyboard_service.dart';
import '../theme/app_theme.dart';

class StoryboardScreen extends StatefulWidget {
  const StoryboardScreen({super.key});

  @override
  State<StoryboardScreen> createState() => _StoryboardScreenState();
}

class _StoryboardScreenState extends State<StoryboardScreen> {
  final StoryboardService _storyboardService = StoryboardService(ApiClient());
  List<Storyboard>? _storyboards;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _storyboardService.getStoryboards();
      if (mounted) setState(() => _storyboards = list);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Storyboards')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_storyboards == null || _storyboards!.isEmpty)
              ? Center(
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _storyboards!.length,
                  itemBuilder: (_, i) =>
                      _StoryboardCard(storyboard: _storyboards![i]),
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
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
