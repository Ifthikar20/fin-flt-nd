import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/deals/deals_bloc.dart';
import '../bloc/deals/deals_event.dart';
import '../theme/app_theme.dart';
import '../widgets/deal_card.dart';
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
      appBar: AppBar(title: const Text('Results')),
      body: BlocBuilder<DealsBloc, DealsState>(
        builder: (context, state) {
          if (state is DealsLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(widget.imagePath),
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('Analyzing image...',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Finding the best deals',
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.imagePath),
                            width: 80,
                            height: 80,
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
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Text('${result.total} deals found',
                                  style: Theme.of(context).textTheme.bodySmall),
                              if (result.searchQueries != null &&
                                  result.searchQueries!.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  children: result.searchQueries!
                                      .take(3)
                                      .map((q) => Chip(
                                            label: Text(q,
                                                style: const TextStyle(fontSize: 10)),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: AppTheme.bgCardLight,
                                            side: const BorderSide(
                                                color: AppTheme.border),
                                          ))
                                      .toList(),
                                ),
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
                if (result.deals.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => DealCard(deal: result.deals[i]),
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
                          Text('No deals found for this item',
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
