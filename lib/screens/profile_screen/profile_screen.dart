import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/screens/my_address_screen/my_address_screen.dart';
import '../login_screen/login_screen.dart';
import '../../utility/animation/open_container_wrapper.dart';
import '../../utility/extensions.dart';
import '../../widget/navigation_tile.dart';
import '../../utility/app_color.dart';
import 'provider/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final userProvider = ref.watch(userProviderNotifier);

    const TextStyle linkStyle =
        TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    const TextStyle titleStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Account",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(
            height: 200,
            child: CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage(
                'assets/images/profile_pic.png',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "${userProvider.getLoginUser()?.name}",
              style: titleStyle,
            ),
          ),
          const SizedBox(height: 40),
          // const OpenContainerWrapper(
          //   nextScreen: MyOrderScreen(),
          //   child: NavigationTile(
          //     icon: Icons.list,
          //     title: 'My Orders',
          //   ),
          // ),
          const SizedBox(height: 15),
          const OpenContainerWrapper(
            nextScreen: MyAddressPage(),
            child: NavigationTile(
              icon: Icons.location_on,
              title: 'My Addresses',
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkOrange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                ref.read(userProviderNotifier).logOutUser();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Logout', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
