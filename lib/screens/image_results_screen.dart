import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/deals/deals_bloc.dart';
import '../bloc/deals/deals_event.dart';
import '../models/deal.dart';
import '../theme/app_theme.dart';
import '../widgets/quota_warning_banner.dart';

class ImageResultsScreen extends StatefulWidget {
  final String imagePath;

  const ImageResultsScreen({super.key, required this.imagePath});

  @override
  State<ImageResultsScreen> createState() => _ImageResultsScreenState();
}

class _ImageResultsScreenState extends State<ImageResultsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DealsBloc>().add(
      DealsImageSearchRequested(imagePath: widget.imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Similar Products')),
      body: BlocBuilder<DealsBloc, DealsState>(
        builder: (context, state) {
          if (state is DealsLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Preview of captured image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(widget.imagePath),
                      width: 160,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('Analyzing your photo...',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Finding similar products across brands',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }

          if (state is DealsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text('Could not analyze image',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DealsBloc>().add(
                      DealsImageSearchRequested(imagePath: widget.imagePath),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DealsLoaded) {
            final result = state.result;
            return CustomScrollView(
              slivers: [
                // Captured image + summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.imagePath),
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (result.extracted?['caption'] != null)
                                Text(
                                  result.extracted!['caption'],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                '${result.total} similar products found',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (result.searchQueries != null &&
                                  result.searchQueries!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: result.searchQueries!
                                      .take(3)
                                      .map((q) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  AppTheme.radiusFull),
                                              border: Border.all(color: AppTheme.border),
                                            ),
                                            child: Text(q,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppTheme.textSecondary)),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (result.quotaWarning != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: QuotaWarningBanner(message: result.quotaWarning!),
                    ),
                  ),

                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      'PRICE COMPARISON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                // Product comparison grid
                if (result.deals.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ComparisonCard(deal: result.deals[i]),
                        childCount: result.deals.length,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          const Icon(Icons.image_not_supported_outlined,
                              size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 16),
                          Text('No similar products found',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Price Comparison Card ────────────────────────
class _ComparisonCard extends StatelessWidget {
  final Deal deal;

  const _ComparisonCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgMain,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (deal.image != null)
                  Image.network(
                    deal.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.bgCard,
                      child: const Icon(Icons.image_outlined,
                          color: AppTheme.textMuted),
                    ),
                  )
                else
                  Container(
                    color: AppTheme.bgCard,
                    child: const Icon(Icons.shopping_bag_outlined,
                        color: AppTheme.textMuted),
                  ),

                // Bookmark
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border,
                        size: 14, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand (uppercase)
                  Text(
                    deal.source.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Title
                  Expanded(
                    child: Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),

                  // Price comparison
                  Row(
                    children: [
                      Text(
                        deal.formattedPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (deal.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          deal.formattedOriginalPrice,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
