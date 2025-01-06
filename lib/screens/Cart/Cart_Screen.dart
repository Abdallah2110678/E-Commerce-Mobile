import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/CartController.dart'; // Import CartController
import 'package:mobile_project/models/product.dart'; // Import Product model
import 'package:mobile_project/utils/constants/colors.dart'; // Import colors
import 'package:mobile_project/utils/constants/sizes.dart'; // Import sizes
import 'package:mobile_project/widgets/images/rounded_image.dart'; // Import RoundedImage widget

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context); // Access CartController

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () {
              cartController.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Your cart has been cleared")),
              );
            },
          ),
        ],
      ),
      body: cartController.items.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18, color: TColors.darkGrey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartController.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartController.items.values.toList()[index];
                      final productId = cartItem.product.id;

                      // Use Dismissible for swipe-to-delete functionality
                      return Dismissible(
                        key: Key(productId), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe from right to left
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                          color: Colors.red, // Background color when swiping
                          child: const Icon(
                            Iconsax.trash,
                            color: TColors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          // Remove the item from the cart
                          cartController.removeItem(productId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${cartItem.product.title} removed from cart"),
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: () {
                                  // Add the item back to the cart
                                  cartController.addItem(cartItem.product);
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: TSizes.defaultSpace,
                            vertical: TSizes.spaceBtwItems / 2,
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(TSizes.sm),
                            child: Row(
                              children: [
                                // Product Image
                                TRoundedImage(
                                  isNetworkImage: true,
                                  imageUrl: cartItem.product.thumbnailUrl,
                                  width: 80,
                                  height: 80,
                                  padding: const EdgeInsets.all(TSizes.sm),
                                  backgroundColor: TColors.light,
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),

                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.product.title,
                                        style: Theme.of(context).textTheme.titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                                      Text(
                                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: TColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Controls
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Iconsax.minus_cirlce, size: 20),
                                      onPressed: () => cartController.decreaseQuantity(productId),
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Iconsax.add_circle, size: 20),
                                      onPressed: () => cartController.addItem(cartItem.product),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Checkout Section
                Container(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  decoration: BoxDecoration(
                    color: TColors.light,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(TSizes.cardRadiusLg),
                      topRight: Radius.circular(TSizes.cardRadiusLg),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${cartController.totalAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ElevatedButton(
                        onPressed: () {
                          // Implement checkout logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Checkout",
                          style: TextStyle(color: TColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}