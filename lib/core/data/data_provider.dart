import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../models/api_response.dart';
import '../../models/category.dart';
import '../../models/brand.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../models/user.dart';
import '../../services/http_services.dart';
import '../../utility/snack_bar_helper.dart';

class DataState {
  final User? user;
  final List<Category> categories;
  final List<SubCategory> subCategories;
  final List<Brand> brands;
  final List<Product> products;
  final List<Poster> posters;
  final List<Order> orders;

  DataState({
    this.user,
    this.categories = const [],
    this.subCategories = const [],
    this.brands = const [],
    this.products = const [],
    this.posters = const [],
    this.orders = const [],
  });

  DataState copyWith({
    User? user,
    List<Category>? categories,
    List<SubCategory>? subCategories,
    List<Brand>? brands,
    List<Product>? products,
    List<Poster>? posters,
    List<Order>? orders,
  }) {
    return DataState(
      user: user ?? this.user,
      categories: categories ?? this.categories,
      subCategories: subCategories ?? this.subCategories,
      brands: brands ?? this.brands,
      products: products ?? this.products,
      posters: posters ?? this.posters,
      orders: orders ?? this.orders,
    );
  }
}

class DataNotifier extends StateNotifier<DataState> {
  final HttpService service = HttpService();

  DataNotifier() : super(DataState()) {
    _initialize();
  }

  void _initialize() {
    getAllProducts();
    getAllCategory();
    getAllSubCategory();
    getAllBrands();
    getAllPosters();
  }

  Future<void> getAllCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'categories');
      if (response.isOk) {
        ApiResponse<List<Category>> apiResponse =
            ApiResponse<List<Category>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Category.fromJson(item)).toList(),
        );
        state = state.copyWith(categories: apiResponse.data ?? []);
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  Future<void> getAllProducts({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'products');
      if (response.isOk) {
        ApiResponse<List<Product>> apiResponse =
            ApiResponse<List<Product>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Product.fromJson(item)).toList(),
        );
        state = state.copyWith(products: apiResponse.data ?? []);
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'brands');
      if (response.isOk) {
        ApiResponse<List<Brand>> apiResponse =
            ApiResponse<List<Brand>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => Brand.fromJson(item)).toList(),
        );
        state = state.copyWith(brands: apiResponse.data ?? []);
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
    }
    return state.brands;
  }

  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      state = state.copyWith(categories: state.categories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      final filteredCategories = state.categories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
      state = state.copyWith(categories: filteredCategories);
    }
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'subCategories');
      if (response.isOk) {
        ApiResponse<List<SubCategory>> apiResponse =
            ApiResponse<List<SubCategory>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => SubCategory.fromJson(item)).toList(),
        );
        final newSubCategories = apiResponse.data ?? [];
        state = state.copyWith(
          subCategories: newSubCategories,
        );
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return state.subCategories;
  }

  void filteredProducts(String keyword) {
    if (keyword.isEmpty) {
      state = state.copyWith(products: state.products);
    } else {
      final lowerKeyword = keyword.toLowerCase();

      final filteredProducts = state.products.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowerKeyword);
        final categoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;
        final subCategoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;

        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword;
      }).toList();

      state = state.copyWith(products: filteredProducts);
    }
  }

  Future<List<Category>> getAllPosters({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'posters');
      if (response.isOk) {
        ApiResponse<List<Poster>> apiResponse =
            ApiResponse<List<Poster>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Poster.fromJson(item)).toList(),
        );
        final newPosters = apiResponse.data ?? [];
        state = state.copyWith(
          posters: newPosters,
        );
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return state.categories;
  }

  double calculateDiscountPercentage(num originalPrice, num? discountedPrice) {
    if (originalPrice <= 0) {
      throw ArgumentError('Original price must be greater than zero.');
    }

    num finalDiscountedPrice = discountedPrice ?? originalPrice;

    if (finalDiscountedPrice > originalPrice) {
      return originalPrice.toDouble();
    }

    double discount =
        ((originalPrice - finalDiscountedPrice) / originalPrice) * 100;

    return discount;
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, DataState>((ref) {
  return DataNotifier();
});

final categoriesProvider =
    Provider((ref) => ref.watch(dataProvider).categories);
final subCategoriesProvider =
    Provider((ref) => ref.watch(dataProvider).subCategories);
final brandsProvider = Provider((ref) => ref.watch(dataProvider).brands);
final productsProvider = Provider((ref) => ref.watch(dataProvider).products);
final postersProvider = Provider((ref) => ref.watch(dataProvider).posters);
final ordersProvider = Provider((ref) => ref.watch(dataProvider).orders);
