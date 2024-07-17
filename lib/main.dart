import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_cart/cart.dart';
import 'package:interview_test/screens/home.dart';
import 'package:interview_test/screens/login_screen/login_screen.dart';
import 'dart:ui' show PointerDeviceKind;

import 'utility/app_theme.dart';
import 'utility/extensions.dart';
import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  var cart = FlutterCart();
  await cart.initializeCart(isPersistenceSupportEnabled: true);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProviderWatch = ref.watch(userProviderNotifier);
    User? loginUser = userProviderWatch.getLoginUser();

    return GetMaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      debugShowCheckedModeBanner: false,
      home: loginUser?.sId == null ? const LoginScreen() : const HomeScreen(),
      theme: AppTheme.lightAppTheme,
    );
  }
}
