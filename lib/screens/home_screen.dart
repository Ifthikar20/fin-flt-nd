import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/deal.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/deal_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/quota_warning_banner.dart';

// Trending deals state
final trendingDealsProvider =
    FutureProvider.autoDispose<SearchResult>((ref) async {
  final dealService = ref.read(dealServiceProvider);
  return dealService.getTrending(limit: 20);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.push('/search?q=${Uri.encodeComponent(query)}');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trending = ref.watch(trendingDealsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ─────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D0D0F), Color(0xFF1A1A2E)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bolt_rounded,
                              size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Fynda',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        // Storyboard button
                        IconButton(
                          onPressed: () => context.push('/storyboard'),
                          icon: const Icon(Icons.dashboard_customize_rounded,
                              size: 22, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Search Bar ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgInput,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search for deals...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                    suffixIcon: GestureDetector(
                      onTap: () => context.push('/camera'),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // ─── Quick Categories ────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(label: '🔥 Trending', onTap: () {}),
                  _CategoryChip(label: '👗 Women', onTap: () => _searchCategory('women fashion')),
                  _CategoryChip(label: '👔 Men', onTap: () => _searchCategory('men fashion')),
                  _CategoryChip(label: '👟 Sneakers', onTap: () => _searchCategory('sneakers')),
                  _CategoryChip(label: '💄 Beauty', onTap: () => _searchCategory('beauty')),
                  _CategoryChip(label: '🏠 Home', onTap: () => _searchCategory('home decor')),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Section Header ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Trending Deals',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Deals Grid ──────────────────────────
          trending.when(
            data: (result) {
              if (result.quotaWarning != null) {
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      QuotaWarningBanner(message: result.quotaWarning!),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }

              if (result.deals.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No deals yet',
                    subtitle: 'Try searching for something!',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final deal = result.deals[index];
                      return DealCard(deal: deal);
                    },
                    childCount: result.deals.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const LoadingShimmer(),
                  childCount: 6,
                ),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: _EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Connection error',
                subtitle: 'Check your internet and try again',
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _searchCategory(String query) {
    context.push('/search?q=${Uri.encodeComponent(query)}');
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.bgCardLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
