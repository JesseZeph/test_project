import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/user.dart';
import '../../../utility/constants.dart';
import '../../../widget/app_bar_action_button.dart';
import '../../../widget/custom_search_bar.dart';
import '../../../core/data/data_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(100);

  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBarActionButton(
              icon: Icons.menu,
              onPressed: () {
                final box = GetStorage();
                Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
                User? userLogged = User.fromJson(userJson ?? {});
                Scaffold.of(context)
                    .openDrawer(); // This might need to be adjusted
              },
            ),
            Expanded(
              child: CustomSearchBar(
                controller: controller,
                onChanged: (val) {
                  ref.read(dataProvider.notifier).filteredProducts(val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
