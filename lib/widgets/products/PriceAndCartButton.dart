import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/texts/product_price_text.dart';

class PriceAndCartButton extends ConsumerWidget {
  final Product product;

  const PriceAndCartButton({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        TProductPriceText(
          price: '${product.discountedPrice.toStringAsFixed(2)}',
          isLarge: false,
        ),

        // Cart Button
        Container(
          decoration: const BoxDecoration(
            color: TColors.dark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(TSizes.cardRadiusMd),
              bottomRight: Radius.circular(TSizes.productImageRadius),
            ),
          ),
          child: IconButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to cart')),
              );
            },
            icon: const Icon(Icons.add, color: TColors.white),
          ),
        ),
      ],
    );
  }
}