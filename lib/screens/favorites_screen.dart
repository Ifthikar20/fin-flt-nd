import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../theme/app_theme.dart';
import '../widgets/deal_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(FavoritesFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Deals'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading || state is FavoritesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('Could not load favorites',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context
                        .read<FavoritesBloc>()
                        .add(FavoritesFetchRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FavoritesLoaded) {
            if (state.deals.isEmpty) {
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
                    Text('Tap ❤️ on any deal to save it here',
                        style: Theme.of(context).textTheme.bodySmall),
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
              itemCount: state.deals.length,
              itemBuilder: (_, i) => DealCard(
                deal: state.deals[i].copyWith(isSaved: true),
                onSave: () => context
                    .read<FavoritesBloc>()
                    .add(FavoritesRemoveRequested(state.deals[i].id)),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
