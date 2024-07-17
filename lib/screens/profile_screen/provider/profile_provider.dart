import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/constants.dart';
import '../../../utility/snack_bar_helper.dart';

class ProfileState {
  final GlobalKey<FormState> addressFormKey;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final TextEditingController couponController;

  ProfileState({
    required this.addressFormKey,
    required this.phoneController,
    required this.streetController,
    required this.cityController,
    required this.stateController,
    required this.postalCodeController,
    required this.countryController,
    required this.couponController,
  });

  ProfileState copyWith({
    GlobalKey<FormState>? addressFormKey,
    TextEditingController? phoneController,
    TextEditingController? streetController,
    TextEditingController? cityController,
    TextEditingController? stateController,
    TextEditingController? postalCodeController,
    TextEditingController? countryController,
    TextEditingController? couponController,
  }) {
    return ProfileState(
      addressFormKey: addressFormKey ?? this.addressFormKey,
      phoneController: phoneController ?? this.phoneController,
      streetController: streetController ?? this.streetController,
      cityController: cityController ?? this.cityController,
      stateController: stateController ?? this.stateController,
      postalCodeController: postalCodeController ?? this.postalCodeController,
      countryController: countryController ?? this.countryController,
      couponController: couponController ?? this.couponController,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final DataNotifier _dataNotifier;
  final box = GetStorage();

  ProfileNotifier(this._dataNotifier)
      : super(ProfileState(
          addressFormKey: GlobalKey<FormState>(),
          phoneController: TextEditingController(),
          streetController: TextEditingController(),
          cityController: TextEditingController(),
          stateController: TextEditingController(),
          postalCodeController: TextEditingController(),
          countryController: TextEditingController(),
          couponController: TextEditingController(),
        )) {
    retrieveSavedAddress();
    _addListeners();
  }

  void _addListeners() {
    state.phoneController.addListener(() => state = state.copyWith());
    state.streetController.addListener(() => state = state.copyWith());
    state.cityController.addListener(() => state = state.copyWith());
    state.stateController.addListener(() => state = state.copyWith());
    state.postalCodeController.addListener(() => state = state.copyWith());
    state.countryController.addListener(() => state = state.copyWith());
    state.couponController.addListener(() => state = state.copyWith());
  }

  void storeAddress() {
    box.write(PHONE_KEY, state.phoneController.text);
    box.write(STREET_KEY, state.streetController.text);
    box.write(CITY_KEY, state.cityController.text);
    box.write(STATE_KEY, state.stateController.text);
    box.write(POSTAL_CODE_KEY, state.postalCodeController.text);
    box.write(COUNTRY_KEY, state.countryController.text);
    SnackBarHelper.showSuccessSnackBar('Address Stored Successfully');
  }

  void retrieveSavedAddress() {
    state.phoneController.text = box.read(PHONE_KEY) ?? '';
    state.streetController.text = box.read(STREET_KEY) ?? '';
    state.cityController.text = box.read(CITY_KEY) ?? '';
    state.stateController.text = box.read(STATE_KEY) ?? '';
    state.postalCodeController.text = box.read(POSTAL_CODE_KEY) ?? '';
    state.countryController.text = box.read(COUNTRY_KEY) ?? '';
    state = state.copyWith(); // Notify listeners of the change
  }

  @override
  void dispose() {
    state.phoneController.dispose();
    state.streetController.dispose();
    state.cityController.dispose();
    state.stateController.dispose();
    state.postalCodeController.dispose();
    state.countryController.dispose();
    state.couponController.dispose();
    super.dispose();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final dataProvider = ref.watch(dataProviderProvider);
  return ProfileNotifier(dataProvider);
});

final dataProviderProvider = Provider<DataNotifier>((ref) => DataNotifier());
