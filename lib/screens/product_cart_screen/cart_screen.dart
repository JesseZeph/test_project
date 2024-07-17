import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/cart_provider.dart';
import '../../utility/animation/animated_switcher_wrapper.dart';
import '../../utility/app_color.dart';
import 'components/buy_now_bottom_sheet.dart';
import 'components/cart_list_section.dart';
import 'components/empty_cart.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.watch(cartProvider.notifier);
    final cartState = ref.watch(cartProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartNotifier.getCartItems();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cartState.myCartItems.isEmpty
              ? const EmptyCart()
              : CartListSection(cartProducts: cartState.myCartItems),
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                ),
                AnimatedSwitcherWrapper(
                  child: Text(
                    "\$${cartNotifier.getCartSubTotal()}",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFEC6813),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: cartState.myCartItems.isEmpty
                    ? null
                    : () {
                        showCustomBottomSheet(context, ref);
                      },
                child: const Text("Buy Now",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
