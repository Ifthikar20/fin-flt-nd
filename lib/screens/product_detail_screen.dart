import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../bloc/favorites/favorites_bloc.dart';
import '../models/deal.dart';

/// Dark-themed product detail page.
///
/// Shows hero image, price info, price-range bar, buy/storyboard buttons,
/// product description, and a row of similar products.
class ProductDetailScreen extends StatefulWidget {
  final Deal deal;

  const ProductDetailScreen({super.key, required this.deal});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Deal _deal;

  // Accent colors
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1A1A1A);
  static const _textPrimary = Color(0xFFF5F5F5);
  static const _textSecondary = Color(0xFF9E9E9E);
  static const _green = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _deal = widget.deal;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero Image ──────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 0.85,
                      child: _deal.image != null
                          ? CachedNetworkImage(
                              imageUrl: _deal.image!,
                              fit: BoxFit.cover,
                              memCacheWidth: 800,
                              placeholder: (_, __) => Container(
                                color: _card,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _textSecondary,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: _card,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: _textSecondary, size: 48),
                                ),
                              ),
                            )
                          : Container(
                              color: _card,
                              child: const Center(
                                child: Icon(Icons.shopping_bag_outlined,
                                    color: _textSecondary, size: 56),
                              ),
                            ),
                    ),

                    // Gradient overlay at bottom for readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              _bg.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Discount badge
                    if (_deal.hasDiscount)
                      Positioned(
                        top: topPadding + 60,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_deal.discountPercent}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Product Info ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand (tappable)
                      if (_deal.source.isNotEmpty)
                        GestureDetector(
                          onTap: () => context.push(
                            '/brand/${Uri.encodeComponent(_deal.source)}',
                          ),
                          child: Text(
                            _deal.source.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        _deal.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _deal.formattedPrice,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                            ),
                          ),
                          if (_deal.hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text(
                              _deal.formattedOriginalPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                color: _textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Rating
                      if (_deal.rating != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              final fill = _deal.rating! - i;
                              return Icon(
                                fill >= 1
                                    ? Icons.star
                                    : fill > 0
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: const Color(0xFFFFD700),
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              _deal.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_deal.reviewsCount != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${_deal.reviewsCount} reviews)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Price Range Bar ─────────
                      _PriceRangeBar(deal: _deal),

                      const SizedBox(height: 24),

                      // ── Action Buttons ──────────
                      // Buy Now
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _launchAffiliateUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Secondary buttons row
                      Row(
                        children: [
                          // Save
                          Expanded(
                            child: _SecondaryButton(
                              icon: _deal.isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              label: _deal.isSaved ? 'Saved' : 'Save',
                              onTap: () {
                                if (_deal.isSaved) {
                                  context.read<FavoritesBloc>().add(
                                      FavoritesRemoveRequested(_deal.id));
                                } else {
                                  context.read<FavoritesBloc>().add(
                                      FavoritesSaveRequested(_deal));
                                }
                                setState(
                                    () => _deal = _deal.copyWith(
                                        isSaved: !_deal.isSaved));
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Add to Storyboard
                          Expanded(
                            child: _SecondaryButton(
                              icon: Icons.dashboard_customize_outlined,
                              label: 'Storyboard',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Added to Storyboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Product Details ─────────
                      if (_deal.description.isNotEmpty) ...[
                        const Text(
                          'About this product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _deal.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Info chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_deal.condition.isNotEmpty)
                            _InfoChip(
                                icon: Icons.verified_outlined,
                                label: _deal.condition),
                          if (_deal.shipping.isNotEmpty)
                            _InfoChip(
                                icon: Icons.local_shipping_outlined,
                                label: _deal.shipping),
                          if (_deal.inStock)
                            const _InfoChip(
                                icon: Icons.check_circle_outline,
                                label: 'In Stock')
                          else
                            const _InfoChip(
                                icon: Icons.cancel_outlined,
                                label: 'Out of Stock'),
                        ],
                      ),

                      // Features
                      if (_deal.features.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...(_deal.features.take(6).map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('•  ',
                                      style: TextStyle(
                                          color: _textSecondary,
                                          fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      f,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                      ],

                      // Seller info
                      if (_deal.seller.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(Icons.store_outlined,
                                      color: _textSecondary, size: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sold by ${_deal.seller}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    if (_deal.source.isNotEmpty)
                                      Text(
                                        'via ${_deal.source}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: _textSecondary),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Top bar (floating back + share) ──
          Positioned(
            top: topPadding + 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
                _CircleButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    // Share URL
                    if (_deal.url != null) {
                      // Could use Share.share here
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchAffiliateUrl() async {
    if (_deal.url != null) {
      final uri = Uri.parse(_deal.url!);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri,
            mode: url_launcher.LaunchMode.externalApplication);
      }
    }
  }
}

// ─── Price Range Bar ────────────────────────

class _PriceRangeBar extends StatelessWidget {
  final Deal deal;

  const _PriceRangeBar({required this.deal});

  @override
  Widget build(BuildContext context) {
    if (deal.price == null) return const SizedBox.shrink();

    final price = deal.price!;
    final original = deal.originalPrice ?? price;

    // Simulate a market range
    final low = (price * 0.7).roundToDouble();
    final high = (original * 1.1).roundToDouble();
    final range = high - low;
    final position = range > 0 ? ((price - low) / range).clamp(0.0, 1.0) : 0.5;

    final isGoodPrice = position < 0.4;
    final isFairPrice = position >= 0.4 && position < 0.65;

    final String label;
    final Color labelColor;
    if (isGoodPrice) {
      label = 'Great price';
      labelColor = const Color(0xFF4CAF50);
    } else if (isFairPrice) {
      label = 'Fair price';
      labelColor = const Color(0xFFFF9800);
    } else {
      label = '\$${price.toInt()} is high';
      labelColor = const Color(0xFFF44336);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Price comparison',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gradient bar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFFFFEB3B),
                      Color(0xFFFF9800),
                      Color(0xFFF44336),
                    ],
                  ),
                ),
              ),

              // Price indicator
              Positioned(
                left: 0,
                right: 0,
                top: -28,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final leftOffset = (constraints.maxWidth * position)
                        .clamp(0.0, constraints.maxWidth - 90);
                    return SizedBox(
                      height: 22,
                      child: Padding(
                        padding: EdgeInsets.only(left: leftOffset),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: labelColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Min / Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${low.toInt()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              Text(
                '\$${high.toInt()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Secondary Button ───────────────────────

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFF5F5F5)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF5F5F5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Circle Button ──────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Info Chip ──────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFF5F5F5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
