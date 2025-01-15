import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () {
              ref.read(cartControllerProvider.notifier).clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Your cart has been cleared")),
              );
            },
          ),
        ],
      ),
      body: cartItems.isEmpty
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
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems.values.toList()[index];
                      final productId = cartItem.product.id;

                      return Dismissible(
                        key: Key(productId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                          color: Colors.red,
                          child: const Icon(
                            Iconsax.trash,
                            color: TColors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          ref.read(cartControllerProvider.notifier).removeItem(productId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${cartItem.product.title} removed from cart"),
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: () {
                                  ref.read(cartControllerProvider.notifier).addItem(cartItem.product);
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
                                TRoundedImage(
                                  isNetworkImage: true,
                                  imageUrl: cartItem.product.thumbnailUrl,
                                  width: 80,
                                  height: 80,
                                  padding: const EdgeInsets.all(TSizes.sm),
                                  backgroundColor: TColors.light,
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Iconsax.minus_cirlce, size: 20),
                                      onPressed: () => ref.read(cartControllerProvider.notifier).decreaseQuantity(productId),
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Iconsax.add_circle, size: 20),
                                      onPressed: () => ref.read(cartControllerProvider.notifier).addItem(cartItem.product),
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
                            '\$${ref.read(cartControllerProvider.notifier).totalAmount.toStringAsFixed(2)}',
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