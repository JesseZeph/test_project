import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:interview_test/widget/product_grid_view.dart';
import 'package:interview_test/utility/app_color.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteState = ref.watch(favoriteNotifierProvider);
    final favoriteNotifier = ref.read(favoriteNotifierProvider.notifier);

    Future.delayed(Duration.zero, () {
      favoriteNotifier.loadFavoriteItems();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: favoriteState.favoriteProducts.isEmpty
            ? const Center(child: Text('No favorite products'))
            : ProductGridView(
                items: favoriteState.favoriteProducts,
              ),
      ),
    );
  }
}
