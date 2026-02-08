import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deal.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/deal_card.dart';

final favoritesProvider =
    FutureProvider.autoDispose<List<Deal>>((ref) async {
  return ref.read(favoritesServiceProvider).getFavorites();
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Deals'),
        automaticallyImplyLeading: false,
      ),
      body: favorites.when(
        data: (deals) {
          if (deals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 56, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('No saved deals yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tap ❤️ on any deal to save it here',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: deals.length,
            itemBuilder: (_, i) => DealCard(
              deal: deals[i].copyWith(isSaved: true),
              onSave: () async {
                await ref.read(favoritesServiceProvider).removeDeal(deals[i].id);
                ref.invalidate(favoritesProvider);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text('Could not load favorites',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(favoritesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
