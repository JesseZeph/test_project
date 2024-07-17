import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/utility/constants.dart';
import '../../../core/data/data_provider.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/product.dart';

class FavoriteState {
  final List<Product> favoriteProducts;

  FavoriteState({this.favoriteProducts = const []});

  FavoriteState copyWith({List<Product>? favoriteProducts}) {
    return FavoriteState(
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
    );
  }
}

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final StateNotifierProviderRef ref;
  final box = GetStorage();

  FavoriteNotifier(this.ref) : super(FavoriteState()) {
    loadFavoriteItems();
  }

  void updateToFavoriteList(String productId) {
    List<dynamic> favoriteList = box.read(FAVORITE_PRODUCT_BOX) ?? [];
    if (favoriteList.contains(productId)) {
      favoriteList.remove(productId);
    } else {
      favoriteList.add(productId);
    }
    box.write(FAVORITE_PRODUCT_BOX, favoriteList);
    loadFavoriteItems();
  }

  bool checkIsItemFavorite(String productId) {
    List<dynamic> favoriteList = box.read(FAVORITE_PRODUCT_BOX) ?? [];
    return favoriteList.contains(productId);
  }

  void loadFavoriteItems() {
    List<dynamic> favoriteListIds = box.read(FAVORITE_PRODUCT_BOX) ?? [];
    final products = ref.read(dataProvider).products;
    final favoriteProducts = products.where((product) {
      return favoriteListIds.contains(product.sId);
    }).toList();
    state = state.copyWith(favoriteProducts: favoriteProducts);
  }

  void clearFavoriteList() {
    box.remove(FAVORITE_PRODUCT_BOX);
    state = state.copyWith(favoriteProducts: []);
  }
}

final favoriteNotifierProvider =
    StateNotifierProvider<FavoriteNotifier, FavoriteState>(
        (ref) => FavoriteNotifier(ref));
