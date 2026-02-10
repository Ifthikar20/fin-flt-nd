import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../models/deal.dart';
import '../theme/app_theme.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback? onSave;
  final bool showTrendingTag;

  const DealCard({
    super.key,
    required this.deal,
    this.onSave,
    this.showTrendingTag = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDeal(context),
      child: Container(
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
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (deal.image != null)
                    CachedNetworkImage(
                      imageUrl: deal.image!,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, __) => Container(
                        color: AppTheme.bgCard,
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              color: AppTheme.textMuted, size: 32),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.bgCard,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppTheme.textMuted, size: 32),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.bgCard,
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined,
                            color: AppTheme.textMuted, size: 32),
                      ),
                    ),

                  // Discount badge (top-left, black pill)
                  if (deal.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${deal.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  // Bookmark button (top-right) — saves deal via FavoritesBloc
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _handleSave(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          deal.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 16,
                          color: deal.isSaved
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                      ),
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
                    // Brand name (tappable → brand page)
                    if (deal.source.isNotEmpty)
                      GestureDetector(
                        onTap: () => context.push(
                          '/brand/${Uri.encodeComponent(deal.source)}',
                        ),
                        child: Text(
                          deal.source.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    const SizedBox(height: 3),

                    // Title
                    Expanded(
                      child: Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),

                    // Trending tag (e.g. #GoodDeal, #TopBrandDeal)
                    if (showTrendingTag)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          deal.trendingTag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
      ),
    );
  }

  void _handleSave(BuildContext context) {
    if (onSave != null) {
      onSave!();
      return;
    }
    // Default: use FavoritesBloc to save/unsave
    if (deal.isSaved) {
      context.read<FavoritesBloc>().add(FavoritesRemoveRequested(deal.id));
    } else {
      context.read<FavoritesBloc>().add(FavoritesSaveRequested(deal));
    }
  }

  Future<void> _openDeal(BuildContext context) async {
    context.push('/deal', extra: deal);
  }
}
