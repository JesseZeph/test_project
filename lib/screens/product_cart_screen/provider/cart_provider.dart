import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:interview_test/utility/utility_extention.dart';
import '../../../models/coupon.dart';
import '../../login_screen/provider/user_provider.dart';
import '../../../services/http_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/api_response.dart';
import '../../../utility/constants.dart';
import '../../../utility/snack_bar_helper.dart';

class CartState {
  final List<CartModel> myCartItems;
  final GlobalKey<FormState> buyNowFormKey;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final TextEditingController couponController;
  final bool isExpanded;
  final Coupon? couponApplied;
  final double couponCodeDiscount;
  final String selectedPaymentOption;
  final FlutterCart flutterCart;

  CartState({
    required this.myCartItems,
    required this.buyNowFormKey,
    required this.phoneController,
    required this.streetController,
    required this.cityController,
    required this.stateController,
    required this.postalCodeController,
    required this.countryController,
    required this.couponController,
    required this.isExpanded,
    this.couponApplied,
    required this.couponCodeDiscount,
    required this.selectedPaymentOption,
    required this.flutterCart,
  });

  CartState copyWith({
    List<CartModel>? myCartItems,
    GlobalKey<FormState>? buyNowFormKey,
    TextEditingController? phoneController,
    TextEditingController? streetController,
    TextEditingController? cityController,
    TextEditingController? stateController,
    TextEditingController? postalCodeController,
    TextEditingController? countryController,
    TextEditingController? couponController,
    bool? isExpanded,
    Coupon? couponApplied,
    double? couponCodeDiscount,
    String? selectedPaymentOption,
    FlutterCart? flutterCart,
  }) {
    return CartState(
      myCartItems: myCartItems ?? this.myCartItems,
      buyNowFormKey: buyNowFormKey ?? this.buyNowFormKey,
      phoneController: phoneController ?? this.phoneController,
      streetController: streetController ?? this.streetController,
      cityController: cityController ?? this.cityController,
      stateController: stateController ?? this.stateController,
      postalCodeController: postalCodeController ?? this.postalCodeController,
      countryController: countryController ?? this.countryController,
      couponController: couponController ?? this.couponController,
      isExpanded: isExpanded ?? this.isExpanded,
      couponApplied: couponApplied ?? this.couponApplied,
      couponCodeDiscount: couponCodeDiscount ?? this.couponCodeDiscount,
      selectedPaymentOption:
          selectedPaymentOption ?? this.selectedPaymentOption,
      flutterCart: flutterCart ?? this.flutterCart,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final HttpService service = HttpService();
  final box = GetStorage();
  final UserNotifier _userNotifier;

  CartNotifier(this._userNotifier)
      : super(CartState(
          myCartItems: [],
          buyNowFormKey: GlobalKey<FormState>(),
          phoneController: TextEditingController(),
          streetController: TextEditingController(),
          cityController: TextEditingController(),
          stateController: TextEditingController(),
          postalCodeController: TextEditingController(),
          countryController: TextEditingController(),
          couponController: TextEditingController(),
          isExpanded: false,
          couponCodeDiscount: 0,
          selectedPaymentOption: 'prepaid',
          flutterCart: FlutterCart(),
        )) {
    retrieveSavedAddress();
  }

  void updateCart(CartModel cartItem, int quantity) {
    quantity = cartItem.quantity + quantity;
    state.flutterCart
        .updateQuantity(cartItem.productId, cartItem.variants, quantity);
    getCartItems();
  }

  double getCartSubTotal() {
    return state.flutterCart.subtotal;
  }

  void getCartItems() {
    state = state.copyWith(myCartItems: state.flutterCart.cartItemsList);
  }

  double getGrandTotal() {
    return getCartSubTotal() - state.couponCodeDiscount;
  }

  void clearCartItems() {
    state.flutterCart.clearCart();
    getCartItems();
  }

  Future<void> checkCoupon() async {
    try {
      if (state.couponController.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Enter a couponcode');
        return;
      }
      List<String> productIds =
          state.myCartItems.map((cartItem) => cartItem.productId).toList();
      Map<String, dynamic> couponData = {
        "couponCode": state.couponController.text,
        "purchaseAmount": getCartSubTotal(),
        "productIds": productIds,
      };
      final response = await service.addItem(
          endpointUrl: 'couponCodes/check-coupon', itemData: couponData);
      if (response.isOk) {
        final ApiResponse<Coupon> apiResponse = ApiResponse<Coupon>.fromJson(
            response.body,
            (json) => Coupon.fromJson(json as Map<String, dynamic>));
        if (apiResponse.success == true) {
          Coupon? coupon = apiResponse.data;
          if (coupon != null) {
            state = state.copyWith(
              couponApplied: coupon,
              couponCodeDiscount: getCouponDiscountAmount(coupon),
            );
          }
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to validate coupon: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      log(e.toString());
      SnackBarHelper.showErrorSnackBar('An error occured: $e');
    }
  }

  double getCouponDiscountAmount(Coupon coupon) {
    double discountAmount = 0;
    String discountType = coupon.discountType ?? 'fixed';
    if (discountType == 'fixed') {
      discountAmount = coupon.discountAmount ?? 0;
      return discountAmount;
    } else {
      double discountPercentage = coupon.discountAmount ?? 0;
      double amountAfterDiscountPercentage =
          getCartSubTotal() * (discountPercentage / 100);
      return amountAfterDiscountPercentage;
    }
  }

  Future<void> addOrder(BuildContext context) async {
    try {
      Map<String, dynamic> order = {
        "userID": _userNotifier.getLoginUser()?.sId ?? '',
        "orderStatus": "pending",
        "items": cartItemToOrderItem(state.myCartItems),
        "totalPrice": getCartSubTotal(),
        "shippingAddress": {
          "phone": state.phoneController.text,
          "street": state.streetController.text,
          "city": state.cityController.text,
          "state": state.stateController.text,
          "postalCode": state.postalCodeController.text,
          "country": state.countryController.text,
        },
        "paymentMethod": state.selectedPaymentOption,
        "couponCode": state.couponApplied?.sId,
        "orderTotal": {
          "subtotal": getCartSubTotal(),
          "discount": state.couponCodeDiscount,
          "total": getGrandTotal(),
        },
      };
      final response =
          await service.addItem(endpointUrl: 'orders', itemData: order);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          clearCouponDiscount();
          clearCartItems();
          Navigator.pop(context);
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message);
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occured: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> cartItemToOrderItem(List<CartModel> cartItems) {
    return cartItems.map((cartItem) {
      return {
        "productID": cartItem.productId,
        "productName": cartItem.productName,
        "quantity": cartItem.quantity,
        "price": cartItem.variants.safeElementAt(0)?.price ?? 0,
        "variant": cartItem.variants.safeElementAt(0)?.color ?? ""
      };
    }).toList();
  }

  Future<void> submitOrder(BuildContext context) async {
    if (state.selectedPaymentOption == 'cod') {
      await addOrder(context);
    } else {
      await stripePayment(operation: () async {
        await addOrder(context);
      });
    }
  }

  void clearCouponDiscount() {
    state = state.copyWith(
      couponApplied: null,
      couponCodeDiscount: 0,
    );
    state.couponController.text = '';
  }

  void retrieveSavedAddress() {
    state = state.copyWith(
      phoneController: TextEditingController(text: box.read(PHONE_KEY) ?? ''),
      streetController: TextEditingController(text: box.read(STREET_KEY) ?? ''),
      cityController: TextEditingController(text: box.read(CITY_KEY) ?? ''),
      stateController: TextEditingController(text: box.read(STATE_KEY) ?? ''),
      postalCodeController:
          TextEditingController(text: box.read(POSTAL_CODE_KEY) ?? ''),
      countryController:
          TextEditingController(text: box.read(COUNTRY_KEY) ?? ''),
    );
  }

  Future<void> stripePayment(
      {required Future<void> Function() operation}) async {
    try {
      Map<String, dynamic> paymentData = {
        "email": _userNotifier.getLoginUser()?.name,
        "name": _userNotifier.getLoginUser()?.name,
        "address": {
          "line1": state.streetController.text,
          "city": state.cityController.text,
          "state": state.stateController.text,
          "postal_code": state.postalCodeController.text,
          "country": "US"
        },
        "amount": getGrandTotal() * 100,
        "currency": "usd",
        "description": "Your transaction description here"
      };
      Response response = await service.addItem(
          endpointUrl: 'payment/stripe', itemData: paymentData);
      final data = await response.body;
      final paymentIntent = data['paymentIntent'];
      final ephemeralKey = data['ephemeralKey'];
      final customer = data['customer'];
      final publishableKey = data['publishableKey'];

      Stripe.publishableKey = publishableKey;
      BillingDetails billingDetails = BillingDetails(
        email: _userNotifier.getLoginUser()?.name,
        phone: '91234123908',
        name: _userNotifier.getLoginUser()?.name,
        address: Address(
            country: 'US',
            city: state.cityController.text,
            line1: state.streetController.text,
            line2: state.stateController.text,
            postalCode: state.postalCodeController.text,
            state: state.stateController.text),
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'FUSIONSTORE',
          paymentIntentClientSecret: paymentIntent,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customer,
          style: ThemeMode.light,
          billingDetails: billingDetails,
        ),
      );

      await Stripe.instance.presentPaymentSheet().then((value) async {
        log('payment success');
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('Payment Success')),
        );
        await operation();
      }).onError((error, stackTrace) {
        if (error is StripeException) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(content: Text('New ${error.error.localizedMessage}')),
          );
        } else {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(content: Text('Stripe Error: $error')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void setSelectedPaymentOption(String option) {
    state = state.copyWith(selectedPaymentOption: option);
  }

  void setIsExpanded(bool expanded) {
    state = state.copyWith(isExpanded: expanded);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final userProvider = ref.watch(userProviderProvider);
  return CartNotifier(userProvider);
});

final userProviderProvider = Provider<UserNotifier>((ref) => UserNotifier());
