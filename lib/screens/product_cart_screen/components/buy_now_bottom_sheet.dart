import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/cart_provider.dart';
import '../../../utility/extensions.dart';
import '../../../widget/compleate_order_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widget/applay_coupon_btn.dart';
import '../../../widget/custom_dropdown.dart';
import '../../../widget/custom_text_field.dart';

void showCustomBottomSheet(BuildContext context, WidgetRef ref) {
  final cartNotifier = ref.read(cartProvider.notifier);
  final cartState = ref.read(cartProvider);
  cartNotifier.clearCouponDiscount();
  cartNotifier.retrieveSavedAddress();
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: cartState.buyNowFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle Address Fields
                ListTile(
                  title: const Text('Enter Address'),
                  trailing: IconButton(
                    icon: Icon(cartState.isExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down),
                    onPressed: () {
                      cartNotifier.setIsExpanded(!cartState.isExpanded);
                    },
                  ),
                ),

                Visibility(
                  visible: cartState.isExpanded,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        CustomTextField(
                          height: 65,
                          labelText: 'Phone',
                          onSave: (value) {},
                          inputType: TextInputType.number,
                          controller: cartState.phoneController,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a phone number'
                              : null,
                        ),
                        CustomTextField(
                          height: 65,
                          labelText: 'Street',
                          onSave: (val) {},
                          controller: cartState.streetController,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a street' : null,
                        ),
                        CustomTextField(
                          height: 65,
                          labelText: 'City',
                          onSave: (value) {},
                          controller: cartState.cityController,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a city' : null,
                        ),
                        CustomTextField(
                          height: 65,
                          labelText: 'State',
                          onSave: (value) {},
                          controller: cartState.stateController,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a state' : null,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                height: 65,
                                labelText: 'Postal Code',
                                onSave: (value) {},
                                inputType: TextInputType.number,
                                controller: cartState.postalCodeController,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a code'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                height: 65,
                                labelText: 'Country',
                                onSave: (value) {},
                                controller: cartState.countryController,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a country'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Payment Options
                CustomDropdown<String>(
                    bgColor: Colors.white,
                    hintText: cartState.selectedPaymentOption,
                    items: const ['cod', 'prepaid'],
                    onChanged: (val) {
                      cartNotifier.setSelectedPaymentOption(val ?? 'prepaid');
                    },
                    displayItem: (val) => val),

                // Coupon Code Field
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 60,
                        labelText: 'Enter Coupon code',
                        onSave: (value) {},
                        controller: cartState.couponController,
                      ),
                    ),
                    ApplyCouponButton(onPressed: () {
                      cartNotifier.checkCoupon();
                    })
                  ],
                ),
                //? Text for Total Amount, Total Offer Applied, and Grand Total
                Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 5, left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total Amount             : \$${cartNotifier.getCartSubTotal()}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(
                            'Total Offer Applied  : \$${cartState.couponCodeDiscount}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(
                            'Grand Total            : \$${cartNotifier.getGrandTotal()}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    )),
                const Divider(),
                //? Pay Button
                CompleteOrderButton(
                    labelText:
                        'Complete Order  \$${cartNotifier.getGrandTotal()} ',
                    onPressed: () {
                      if (!cartState.isExpanded) {
                        cartNotifier.setIsExpanded(true);
                        return;
                      }
                      // Check if the form is valid
                      if (cartState.buyNowFormKey.currentState!.validate()) {
                        cartState.buyNowFormKey.currentState!.save();
                        cartNotifier.submitOrder(context);
                        return;
                      }
                    })
              ],
            ),
          ),
        ),
      );
    },
    isScrollControlled: true,
  );
}
