import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/wishlist_controller.dart';
import 'package:mobile_project/screens/home/appbar.dart';
import 'package:mobile_project/screens/home/home.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/icons/circular_icon.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return Scaffold(
      appBar: TAppbar(
        title:
            Text('Wishlist', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          TCircularIcon(
            icon: Iconsax.add,
            onPressed: () => Get.to(HomeScreen()),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Obx(
            () => TGridLayout(
              itemCount: wishlistController.wishlistItems.length,
              itemBuilder: (_, index) => TProductCardVertical(
                product: wishlistController.wishlistItems[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
