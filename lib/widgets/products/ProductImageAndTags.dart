import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/icons/circular_icon.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';

class ProductImageAndTags extends StatelessWidget {
  final Product product;
  final bool isHomeScreen;
  final WishlistController wishlistController;

  const ProductImageAndTags({
    Key? key,
    required this.product,
    required this.isHomeScreen,
    required this.wishlistController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                onTap: () => wishlistController.toggleWishlist(product),
                child: TCircularIcon(
                  icon: wishlistController.isInWishlist(product)
                      ? Iconsax.heart5
                      : Iconsax.heart,
                  color: wishlistController.isInWishlist(product)
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
}