import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:interview_test/models/product.dart';
import 'package:interview_test/utility/snack_bar_helper.dart';
import 'package:interview_test/utility/utility_extention.dart';

class ProductDetailState {
  final String? selectedVariant;
  final FlutterCart flutterCart;

  ProductDetailState({this.selectedVariant, FlutterCart? flutterCart})
      : flutterCart = flutterCart ?? FlutterCart();

  ProductDetailState copyWith({
    String? selectedVariant,
    FlutterCart? flutterCart,
  }) {
    return ProductDetailState(
      selectedVariant: selectedVariant ?? this.selectedVariant,
      flutterCart: flutterCart ?? this.flutterCart,
    );
  }
}

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier() : super(ProductDetailState());

  void setSelectedVariant(String? variant) {
    state = state.copyWith(selectedVariant: variant);
  }

  void addToCart(Product product) {
    if (product.proVariantId!.isNotEmpty && state.selectedVariant == null) {
      SnackBarHelper.showErrorSnackBar('Please select a variant');
      return;
    }
    double? price = product.offerPrice != product.price
        ? product.offerPrice
        : product.price;
    state.flutterCart.addToCart(
        cartModel: CartModel(
            productId: '${product.sId}',
            productName: '${product.name}',
            productImages: ['${product.images?.safeElementAt(0)?.url}'],
            variants: [
              ProductVariant(price: price ?? 0, color: state.selectedVariant)
            ],
            productDetails: '${product.description}'));
    state = state.copyWith(selectedVariant: null);
    SnackBarHelper.showSuccessSnackBar('Item Added');
  }
}

final productDetailNotifierProvider =
    StateNotifierProvider<ProductDetailNotifier, ProductDetailState>(
        (ref) => ProductDetailNotifier());
