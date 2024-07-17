import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/screens/profile_screen/provider/profile_provider.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_text_field.dart';

class MyAddressPage extends ConsumerWidget {
  const MyAddressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Address",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: profileState.addressFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    surfaceTintColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            labelText: 'Phone',
                            onSave: (value) {},
                            inputType: TextInputType.number,
                            controller: profileState.phoneController,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a phone number'
                                : null,
                          ),
                          CustomTextField(
                            labelText: 'Street',
                            onSave: (val) {},
                            controller: profileState.streetController,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a street' : null,
                          ),
                          CustomTextField(
                            labelText: 'City',
                            onSave: (value) {},
                            controller: profileState.cityController,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a city' : null,
                          ),
                          CustomTextField(
                            labelText: 'State',
                            onSave: (value) {},
                            controller: profileState.stateController,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a state' : null,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  labelText: 'Postal Code',
                                  onSave: (value) {},
                                  inputType: TextInputType.number,
                                  controller: profileState.postalCodeController,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter a code'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomTextField(
                                  labelText: 'Country',
                                  onSave: (value) {},
                                  controller: profileState.countryController,
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
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.darkOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        if (profileState.addressFormKey.currentState!
                            .validate()) {
                          profileNotifier.storeAddress();
                        }
                      },
                      child: const Text('Update Address',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
