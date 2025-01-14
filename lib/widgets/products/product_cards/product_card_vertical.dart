import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/screens/Cart/Cart_Screen.dart';
import 'package:provider/provider.dart'; // Import Provider for CartController
import 'package:mobile_project/controllers/wishlist_controller.dart'; // Import WishlistController
import 'package:mobile_project/models/product.dart'; // Import Product model
import 'package:mobile_project/screens/styles/shadows.dart'; // Import shadows
import 'package:mobile_project/utils/constants/colors.dart'; // Import colors
import 'package:mobile_project/utils/constants/sizes.dart'; // Import sizes
import 'package:mobile_project/utils/helpers/helper_functions.dart'; // Import helper functions
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart'; // Import RoundedContainer
import 'package:mobile_project/widgets/icons/circular_icon.dart'; // Import CircularIcon
import 'package:mobile_project/widgets/images/rounded_image.dart'; // Import RoundedImage
import 'package:mobile_project/widgets/products/product_cards/product_decription.dart'; // Import ProductDescriptionPage
import 'package:mobile_project/widgets/texts/product_price_text.dart'; // Import ProductPriceText

class TProductCardVertical extends StatelessWidget {
  final Product product;
  final bool isHomeScreen;

  TProductCardVertical({
    Key? key,
    required this.product,
    this.isHomeScreen = true,
  }) : super(key: key);

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
            // Product Image and Tags
            _buildProductImageAndTags(context),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProductTitle(context, darkMode),
                    if (!isHomeScreen) _buildProductBrand(context, darkMode),
                    const Spacer(),
                    _buildPriceAndCartButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageAndTags(BuildContext context) {
    return SizedBox(
      height: isHomeScreen ? 120 : 160,
      child: Stack(
        children: [
          // Product Image
          TRoundedImage(
            isNetworkImage: true,
            imageUrl: product.thumbnailUrl,
            applyImageRadius: true,
          ),

          // Discount Tag
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

          // Favorite Icon
          Positioned(
            top: 0,
            right: 0,
            child: Obx(
              () => GestureDetector(
                onTap: () => _wishlistController.toggleWishlist(product),
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
    );
  }

  Widget _buildProductTitle(BuildContext context, bool darkMode) {
    return Text(
      product.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: darkMode ? TColors.white : TColors.dark,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildProductBrand(BuildContext context, bool darkMode) {
    return Row(
      children: [
        if (product.brand.logoUrl.isNotEmpty) ...[
          CircleAvatar(
            backgroundImage: NetworkImage(product.brand.logoUrl),
            radius: TSizes.iconXs,
          ),
          const SizedBox(width: TSizes.xs),
        ],
        Expanded(
          child: Text(
            product.brand.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: darkMode ? TColors.white : TColors.dark,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndCartButton(BuildContext context) {
    final cartController = Provider.of<CartController>(
        context); // Access CartController using Provider

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        TProductPriceText(
          price: '\$${product.discountedPrice.toStringAsFixed(2)}',
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
              cartController.addItem(product);
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
