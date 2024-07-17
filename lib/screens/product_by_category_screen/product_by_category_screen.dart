import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/utility/extensions.dart';
import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/sub_category.dart';
import 'provider/product_by_category_provider.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_dropdown.dart';
import '../../widget/multi_select_drop_down.dart';
import '../../widget/horizondal_list.dart';
import '../../widget/product_grid_view.dart';

class ProductByCategoryScreen extends ConsumerStatefulWidget {
  final Category selectedCategory;

  const ProductByCategoryScreen({super.key, required this.selectedCategory});

  @override
  ConsumerState<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState
    extends ConsumerState<ProductByCategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(productbyCategoryNotifierProvider.notifier)
        .filterInitialProductAndSubCategory(widget.selectedCategory));
  }

  @override
  Widget build(BuildContext context) {
    final proByCatProvider = ref.watch(productbyCategoryNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                "${widget.selectedCategory.name}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkOrange),
              ),
              expandedHeight: 190.0,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  var top = constraints.biggest.height -
                      MediaQuery.of(context).padding.top;
                  return Stack(
                    children: [
                      Positioned(
                        top: top - 145,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: HorizontalList(
                                items: proByCatProvider.subCategories,
                                itemToString: (SubCategory? val) =>
                                    val?.name ?? '',
                                selected: proByCatProvider.selectedSubCategory,
                                onSelect: (val) {
                                  if (val != null) {
                                    ref
                                        .read(productbyCategoryNotifierProvider
                                            .notifier)
                                        .filterProductBySubCategory(val);
                                  }
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDropdown<String>(
                                    hintText: 'Sort By Price',
                                    items: const ['Low To High', 'High To Low'],
                                    onChanged: (val) {
                                      if (val?.toLowerCase() == 'low to high') {
                                        ref
                                            .read(
                                                productbyCategoryNotifierProvider
                                                    .notifier)
                                            .sortProducts(ascending: true);
                                      } else {
                                        ref
                                            .read(
                                                productbyCategoryNotifierProvider
                                                    .notifier)
                                            .sortProducts(ascending: false);
                                      }
                                    },
                                    displayItem: (val) => val,
                                  ),
                                ),
                                Expanded(
                                  child: MultiSelectDropDown<Brand>(
                                    hintText: 'Filter By Brands',
                                    items: proByCatProvider.brands,
                                    onSelectionChanged: (val) {
                                      ref
                                          .read(
                                              productbyCategoryNotifierProvider
                                                  .notifier)
                                          .filterProductByBrand();
                                    },
                                    displayItem: (val) => val.name ?? '',
                                    selectedItems:
                                        proByCatProvider.selectedBrands,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: ProductGridView(
                  items: proByCatProvider.filteredProducts,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
