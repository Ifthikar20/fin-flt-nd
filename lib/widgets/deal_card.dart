import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/deal.dart';
import '../theme/app_theme.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback? onSave;

  const DealCard({super.key, required this.deal, this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDeal(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border, width: 0.5),
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
                      placeholder: (_, __) => Container(
                        color: AppTheme.bgCardLight,
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              color: AppTheme.textMuted, size: 32),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.bgCardLight,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppTheme.textMuted, size: 32),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.bgCardLight,
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined,
                            color: AppTheme.textMuted, size: 32),
                      ),
                    ),

                  // Discount badge
                  if (deal.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${deal.discount}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Save button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onSave,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          deal.isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: deal.isSaved
                              ? AppTheme.error
                              : Colors.white,
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source badge
                    if (deal.source.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          deal.source,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),

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

                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          deal.formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (deal.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            deal.formattedOriginalPrice,
                            style: TextStyle(
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

  Future<void> _openDeal(BuildContext context) async {
    if (deal.url != null) {
      final uri = Uri.parse(deal.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
