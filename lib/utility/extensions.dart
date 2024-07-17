import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/core/data/data_provider.dart';
import 'package:interview_test/screens/login_screen/provider/user_provider.dart';
import 'package:interview_test/screens/product_by_category_screen/provider/product_by_category_provider.dart';
import 'package:interview_test/screens/product_details_screen/provider/product_detail_provider.dart';

final dataNotifierProvider = Provider((ref) => DataNotifier());

final userProviderNotifier = Provider((ref) => UserNotifier());

final productbyCategoryNotifierProvider =
    StateNotifierProvider<ProductByCategoryNotifier, ProductByCategoryState>(
        (ref) => ProductByCategoryNotifier(ref));

final productDetailNotifierProvider =
    Provider((ref) => ProductDetailNotifier());

extension Providers on WidgetRef {
  DataNotifier get dataNotifier => read(dataNotifierProvider);
  UserNotifier get userNotifier => read(userProviderNotifier);

  ProductByCategoryNotifier get productByCategoryNotifier =>
      read(productbyCategoryNotifierProvider.notifier);
}
