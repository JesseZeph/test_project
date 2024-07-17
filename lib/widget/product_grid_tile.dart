import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_test/screens/product_favorite_screen/provider/favorite_provider.dart';
import 'package:interview_test/utility/extensions.dart';
import 'package:interview_test/utility/utility_extention.dart';

import '../models/product.dart';
import 'custom_network_image.dart';

class ProductGridTile extends ConsumerWidget {
  final Product product;
  final int index;
  final bool isPriceOff;

  const ProductGridTile({
    super.key,
    required this.product,
    required this.index,
    required this.isPriceOff,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double discountPercentage = ref
        .read(dataNotifierProvider)
        .calculateDiscountPercentage(
            product.price ?? 0, product.offerPrice ?? 0);
    final favoriteNotifier = ref.watch(favoriteNotifierProvider.notifier);
    final isFavorite = ref.watch(favoriteNotifierProvider.select((state) =>
        state.favoriteProducts
            .any((favoriteProduct) => favoriteProduct.sId == product.sId)));

    return GridTile(
      header: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: discountPercentage != 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                width: 80,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  "OFF ${discountPercentage.toInt()} %",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: isFavorite ? Colors.red : const Color(0xFFA6A3A0),
              ),
              onPressed: () {
                favoriteNotifier.updateToFavoriteList(product.sId ?? '');
              },
            ),
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  product.name ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      product.offerPrice != 0
                          ? "\$${product.offerPrice}"
                          : "\$${product.price}",
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  if (product.offerPrice != null &&
                      product.offerPrice != product.price)
                    Flexible(
                      child: Text(
                        "\$${product.price}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E6E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomNetworkImage(
          imageUrl: product.images!.isNotEmpty
              ? product.images?.safeElementAt(0)?.url ?? ''
              : '',
          fit: BoxFit.scaleDown,
          scale: 3.0,
        ),
      ),
    );
  }
}
