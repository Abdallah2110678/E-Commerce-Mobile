import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/screens/styles/shadows.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/icons/circular_icon.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/products/product_cards/product_decription.dart';
import 'package:mobile_project/widgets/texts/product_price_text.dart';

class TProductCardVertical extends StatelessWidget {
  final Product product;
  final bool isHomeScreen;

  TProductCardVertical({
    super.key,
    required this.product,
    this.isHomeScreen = true,
  });

  final WishlistController _wishlistController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDescriptionPage(productId: product.id),
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
            /// Product Image and Tags
            SizedBox(
              height: isHomeScreen ? 120 : 160,
              child: Stack(
                children: [
                  /// Product Image
                  TRoundedImage(
                    isNetworkImage: true,
                    imageUrl: product.thumbnailUrl,
                    applyImageRadius: true,
                  ),

                  /// Discount Tag
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: TRoundedContainer(
                        radius: TSizes.sm,
                        backgroundColor: TColors.secondary.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm,
                          vertical: TSizes.xs,
                        ),
                        child: Text(
                          '${product.discount}%',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color: TColors.black,
                              ),
                        ),
                      ),
                    ),

                  /// Favorite Icon
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Obx(
                      () => GestureDetector(
                        onTap: () =>
                            _wishlistController.toggleWishlist(product),
                        child: TCircularIcon(
                          icon: _wishlistController.isInWishlist(product)
                              ? Iconsax.heart5
                              : Iconsax.heart,
                          color: _wishlistController.isInWishlist(product)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Title
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: darkMode ? TColors.white : TColors.dark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    if (!isHomeScreen) const SizedBox(height: TSizes.xs / 2),

                    /// Brand
                    if (!isHomeScreen)
                      Row(
                        children: [
                          if (product.brand.logoUrl.isNotEmpty) ...[
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(product.brand.logoUrl),
                              radius: TSizes.iconXs,
                            ),
                            const SizedBox(width: TSizes.xs),
                          ],
                          Expanded(
                            child: Text(
                              product.brand.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color:
                                        darkMode ? TColors.white : TColors.dark,
                                  ),
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    /// Price and Cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Price
                        TProductPriceText(
                          price:
                              '\$${product.discountedPrice.toStringAsFixed(2)}',
                          isLarge: false,
                        ),

                        /// Cart Button
                        Container(
                          decoration: const BoxDecoration(
                            color: TColors.dark,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(TSizes.cardRadiusMd),
                              bottomRight:
                                  Radius.circular(TSizes.productImageRadius),
                            ),
                          ),
                          child: const SizedBox(
                            width: TSizes.iconLg,
                            height: TSizes.iconLg,
                            child: Center(
                              child: Icon(
                                Iconsax.add,
                                color: TColors.white,
                                size: TSizes.iconSm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
