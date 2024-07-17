import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:interview_test/screens/home.dart';
import '../../utility/app_color.dart';
import 'provider/user_provider.dart'; // Make sure this import points to your new Riverpod user provider

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterLogin(
      // savedEmail: 'testing@gmail.com',
      // savedPassword: '12345',
      loginAfterSignUp: false,
      logo: const AssetImage('assets/images/logo.png'),
      onLogin: (LoginData loginData) async {
        await ref.read(userProvider.notifier).login(loginData);
      },
      onSignup: (SignupData data) async {
        await ref.read(userProvider.notifier).register(data);
      },
      onSubmitAnimationCompleted: () {
        final user = ref.read(currentUserProvider);
        if (user?.sId != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
        }
      },
      onRecoverPassword: (_) => null,
      hideForgotPasswordButton: true,
      theme: LoginTheme(
        primaryColor: AppColor.darkGrey,
        accentColor: AppColor.darkOrange,
        buttonTheme: const LoginButtonTheme(
          backgroundColor: AppColor.darkOrange,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        titleStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}
