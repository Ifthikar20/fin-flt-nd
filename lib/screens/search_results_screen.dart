import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deal.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/deal_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/quota_warning_banner.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  SearchResult? _result;
  bool _loading = true;
  String _sort = 'relevance';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _search(widget.query);
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _loading = true);
    try {
      final result = await ref.read(dealServiceProvider).search(
            query: query,
            sort: _sort,
          );
      if (mounted) setState(() => _result = result);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            onSubmitted: _search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search deals...',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.bgInput,
              prefixIcon: const Icon(Icons.search, size: 18),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, size: 20),
            onSelected: (sort) {
              _sort = sort;
              _search(_searchController.text);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'relevance', child: Text('Relevance')),
              const PopupMenuItem(value: 'price_low', child: Text('Price: Low → High')),
              const PopupMenuItem(value: 'price_high', child: Text('Price: High → Low')),
              const PopupMenuItem(value: 'rating', child: Text('Top Rated')),
            ],
          ),
        ],
      ),
      body: _loading
          ? GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const LoadingShimmer(),
            )
          : _result == null || _result!.deals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off,
                          size: 56, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text('No results for "${widget.query}"',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Try different keywords',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_result!.quotaWarning != null) ...[
                      const SizedBox(height: 8),
                      QuotaWarningBanner(message: _result!.quotaWarning!),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            '${_result!.total} results',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            '${_result!.searchTimeMs}ms',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _result!.deals.length,
                        itemBuilder: (_, i) =>
                            DealCard(deal: _result!.deals[i]),
                      ),
                    ),
                  ],
                ),
    );
  }
}
