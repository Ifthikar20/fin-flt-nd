import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deal.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/deal_card.dart';
import '../widgets/quota_warning_banner.dart';

class ImageResultsScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ImageResultsScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ImageResultsScreen> createState() =>
      _ImageResultsScreenState();
}

class _ImageResultsScreenState extends ConsumerState<ImageResultsScreen> {
  SearchResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uploadAndSearch();
  }

  Future<void> _uploadAndSearch() async {
    try {
      final result = await ref
          .read(dealServiceProvider)
          .imageSearch(File(widget.imagePath));
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show uploaded image
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
                      strokeWidth: 3,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Analyzing image...',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Finding the best deals',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
          : _error != null
              ? Center(
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
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _uploadAndSearch();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Image preview + extracted info
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
                                  if (_result?.extracted?['caption'] != null)
                                    Text(
                                      _result!.extracted!['caption'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_result?.total ?? 0} deals found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  if (_result?.searchQueries != null &&
                                      _result!.searchQueries!.isNotEmpty)
                                    Wrap(
                                      spacing: 6,
                                      children: _result!.searchQueries!
                                          .take(3)
                                          .map((q) => Chip(
                                                label: Text(q,
                                                    style: const TextStyle(
                                                        fontSize: 10)),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding: EdgeInsets.zero,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                backgroundColor:
                                                    AppTheme.bgCardLight,
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

                    if (_result?.quotaWarning != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: QuotaWarningBanner(
                              message: _result!.quotaWarning!),
                        ),
                      ),

                    // Results grid
                    if (_result != null && _result!.deals.isNotEmpty)
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
                            (_, i) => DealCard(deal: _result!.deals[i]),
                            childCount: _result!.deals.length,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              const SizedBox(height: 4),
                              Text('Try a clearer product photo',
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
    );
  }
}
