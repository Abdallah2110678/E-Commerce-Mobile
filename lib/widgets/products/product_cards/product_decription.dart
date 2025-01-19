import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';
import 'package:mobile_project/widgets/texts/product_price_text.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';


class ProductDescriptionPage extends ConsumerWidget {
  final Product product;

   ProductDescriptionPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: dark ? TColors.black : TColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ListView(
          children: [
            /// Product Thumbnail
            TRoundedImage(
              isNetworkImage: true,
              imageUrl: product.thumbnailUrl,
              height: 250,
              applyImageRadius: true,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Product Title and Brand
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: TSizes.sm),
                TBrandTitleWithVerifiedIcon(
                  title: product.brand.name,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Product Price and Discount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TProductPriceText(
                  price: product.price.toStringAsFixed(2),
                ),
                if (product.discount > 0)
                  TRoundedContainer(
                    radius: TSizes.sm,
                    backgroundColor: TColors.secondary.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.sm,
                      vertical: TSizes.xs,
                    ),
                    child: Text(
                      '${product.discount}% Off',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .apply(color: TColors.black),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Product Description
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Add to Cart Button
            ElevatedButton(
              onPressed: () {
                // Use .read to access the CartController and add the product to the cart
                ref.read(cartControllerProvider.notifier).addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added to cart')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: TSizes.defaultSpace),
                backgroundColor: TColors.dark,
                minimumSize: const Size(double.infinity, 50), // Full width
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(color: TColors.white),
              ),
            ),

            /// Ratings and Comments Section
            const SizedBox(height: TSizes.spaceBtwSections),
            Text(
              'Ratings & Reviews',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ...product.ratingComments.map((rc) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(rc.userName[0]), // Display user's initial
                ),
                title: Text(rc.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: TSizes.xs),
                        Text(
                          rc.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(rc.comment),
                  ],
                ),
                trailing: Text(
                  DateFormat('dd MMM yyyy').format(rc.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}