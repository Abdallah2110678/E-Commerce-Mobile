import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/screens/styles/shadows.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/products/PriceAndCartButton.dart';
import 'package:mobile_project/widgets/products/ProductBrand.dart';
import 'package:mobile_project/widgets/products/ProductImageAndTags.dart';
import 'package:mobile_project/widgets/products/ProductTitle.dart';
import 'package:mobile_project/widgets/products/product_cards/product_decription.dart';

class TProductCardVertical extends ConsumerWidget {
  final Product product;
  final bool isHomeScreen;

  TProductCardVertical({
    Key? key,
    required this.product,
    this.isHomeScreen = true,
  }) : super(key: key);

  final WishlistController _wishlistController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDescriptionPage(product: product),
          ),
        );
      },
      child: Container(
        width: 180,
        height: isHomeScreen ? 240 : 300, // Adjust height based on screen
        margin: const EdgeInsets.symmetric(horizontal: TSizes.sm),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: darkMode ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image and Tags
            ProductImageAndTags(
              product: product,
              isHomeScreen: isHomeScreen,
              wishlistController: _wishlistController,
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProductTitle(product: product, darkMode: darkMode),
                    if (!isHomeScreen) ProductBrand(product: product, darkMode: darkMode),
                    const Spacer(),
                    PriceAndCartButton(product: product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}