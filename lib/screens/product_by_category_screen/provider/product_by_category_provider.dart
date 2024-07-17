import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';

class ProductByCategoryState {
  final Category? selectedCategory;
  final SubCategory? selectedSubCategory;
  final List<SubCategory> subCategories;
  final List<Brand> brands;
  final List<Brand> selectedBrands;
  final List<Product> filteredProducts;

  ProductByCategoryState({
    this.selectedCategory,
    this.selectedSubCategory,
    this.subCategories = const [],
    this.brands = const [],
    this.selectedBrands = const [],
    this.filteredProducts = const [],
  });

  ProductByCategoryState copyWith({
    Category? selectedCategory,
    SubCategory? selectedSubCategory,
    List<SubCategory>? subCategories,
    List<Brand>? brands,
    List<Brand>? selectedBrands,
    List<Product>? filteredProducts,
  }) {
    return ProductByCategoryState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      subCategories: subCategories ?? this.subCategories,
      brands: brands ?? this.brands,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      filteredProducts: filteredProducts ?? this.filteredProducts,
    );
  }
}

class ProductByCategoryNotifier extends StateNotifier<ProductByCategoryState> {
  final StateNotifierProviderRef ref;

  ProductByCategoryNotifier(this.ref) : super(ProductByCategoryState());

  void filterInitialProductAndSubCategory(Category selectedCategory) {
    final dataState = ref.read(dataProvider);
    final subCategories = dataState.subCategories
        .where((element) => element.categoryId?.sId == selectedCategory.sId)
        .toList();
    subCategories.insert(0, SubCategory(name: 'All'));
    final filteredProducts = dataState.products
        .where(
            (element) => element.proCategoryId?.name == selectedCategory.name)
        .toList();

    state = state.copyWith(
      selectedCategory: selectedCategory,
      selectedSubCategory: SubCategory(name: 'All'),
      subCategories: subCategories,
      filteredProducts: filteredProducts,
    );
  }

  void filterProductBySubCategory(SubCategory subCategory) {
    final dataState = ref.read(dataProvider);
    List<Product> filteredProducts;
    List<Brand> brands;

    if (subCategory.name?.toLowerCase() == 'all') {
      filteredProducts = dataState.products
          .where((element) =>
              element.proCategoryId?.sId == state.selectedCategory?.sId)
          .toList();
      brands = [];
    } else {
      filteredProducts = dataState.products
          .where(
              (element) => element.proSubCategoryId?.name == subCategory.name)
          .toList();
      brands = dataState.brands
          .where((element) => element.subcategoryId?.sId == subCategory.sId)
          .toList();
    }

    state = state.copyWith(
      selectedSubCategory: subCategory,
      filteredProducts: filteredProducts,
      brands: brands,
    );
  }

  void filterProductByBrand() {
    final dataState = ref.read(dataProvider);
    List<Product> filteredProducts;

    if (state.selectedBrands.isEmpty) {
      filteredProducts = dataState.products
          .where((product) =>
              product.proSubCategoryId?.name == state.selectedSubCategory?.name)
          .toList();
    } else {
      filteredProducts = dataState.products
          .where((product) =>
              product.proSubCategoryId?.name ==
                  state.selectedSubCategory?.name &&
              state.selectedBrands
                  .any((brand) => product.proBrandId?.sId == brand.sId))
          .toList();
    }

    state = state.copyWith(filteredProducts: filteredProducts);
  }

  void sortProducts({required bool ascending}) {
    final sortedProducts = List<Product>.from(state.filteredProducts)
      ..sort((a, b) {
        if (ascending) {
          return a.price!.compareTo(b.price ?? 0);
        } else {
          return b.price!.compareTo(a.price ?? 0);
        }
      });

    state = state.copyWith(filteredProducts: sortedProducts);
  }

  void toggleBrandSelection(Brand brand) {
    final updatedSelectedBrands = List<Brand>.from(state.selectedBrands);
    if (updatedSelectedBrands.contains(brand)) {
      updatedSelectedBrands.remove(brand);
    } else {
      updatedSelectedBrands.add(brand);
    }
    state = state.copyWith(selectedBrands: updatedSelectedBrands);
    filterProductByBrand();
  }
}
