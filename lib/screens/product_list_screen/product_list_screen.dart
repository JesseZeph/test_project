import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/core/data/data_provider.dart';
import 'package:interview_test/utility/extensions.dart';
import 'components/custom_app_bar.dart';
import 'components/category_selector.dart';
import 'components/poster_section.dart';

import '../../../../widget/product_grid_view.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataNotifier = ref.watch(dataNotifierProvider);
    final categories = ref.watch(dataProvider).categories;
    final products = ref.watch(dataProvider).products;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataNotifier.getAllCategory(showSnack: false);
      dataNotifier.getAllProducts(showSnack: false);
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello Chief",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  "Lets gets somethings?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 15),
                const PosterSection(),
                const SizedBox(height: 15),
                Text(
                  "Top categories",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 15),
                CategorySelector(categories: categories),
                const SizedBox(height: 20),
                ProductGridView(items: products),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
