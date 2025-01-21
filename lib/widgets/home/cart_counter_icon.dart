import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/screens/Cart/Cart_Screen.dart';
import 'package:mobile_project/utils/constants/colors.dart';

class TCartCounterIcon extends ConsumerWidget {
  const TCartCounterIcon({super.key, required this.onPressed, this.iconColor});

  final Color? iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      // Use .watch to listen to the cart state
      final cartItems = ref.watch(cartControllerProvider);

      return Stack(
        children: [
          // Cart Icon Button
          IconButton(
            onPressed: () {
              // Navigate to the cart screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: Icon(Iconsax.shopping_bag, color: iconColor),
          ),

          // Cart Item Counter
          Positioned(
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: TColors.black
                    .withOpacity(0.5), // Background color of the counter
                borderRadius: BorderRadius.circular(100), // Circular shape
              ),
              child: Center(
                child: Text(
                  '${cartItems.length}', // Display the number of items in the cart
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                        color: TColors.white,
                        fontSizeFactor: 0.8, 
                      ),
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to use the cart')),
          );
        },
        icon: Icon(Iconsax.shopping_bag, color: iconColor),
      );
    }
  }
}
