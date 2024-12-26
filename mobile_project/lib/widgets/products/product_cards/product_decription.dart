import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';
import 'package:mobile_project/widgets/texts/product_price_text.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';

class ProductDescriptionPage extends StatelessWidget {
  final String productId;

  const ProductDescriptionPage({
    super.key,
    required this.productId,
  });

  Future<Map<String, dynamic>> _fetchProductDetails() async {
    // Fetch product details from Firestore
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (!productDoc.exists) {
      throw Exception('Product not found');
    }

    // Fetch the brand details
    final productData = productDoc.data()!;
    final brandDoc = await FirebaseFirestore.instance
        .collection('brands')
        .doc(productData['brandId'])
        .get();

    final brandData = brandDoc.exists ? brandDoc.data() : null;
    

    return {
      'product': productData,
      'brand': brandData,
    };
  }

  @override
  Widget build(BuildContext context) {
       final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: THelperFunctions.isDarkMode(context)
            ? TColors.black
            : TColors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading product details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!['product'];
          final brandData = snapshot.data!['brand'];

          return Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: ListView(
              children: [
                /// Product Thumbnail
                TRoundedImage(
                  imageUrl: productData['thumbnailUrl'],
                  height: 250,
                  applyImageRadius: true,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Product Title and Brand
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData['title'] ?? 'No title',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: TSizes.sm),
                    if (brandData != null)
                      TBrandTitleWithVerifiedIcon(
                        title: brandData['name'] ?? 'Unknown Brand',
                      ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Product Price and Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TProductPriceText(
                      price: productData['price'].toStringAsFixed(2),
                    ),
                    if (productData['discount'] > 0)
                      TRoundedContainer(
                        radius: TSizes.sm,
                        backgroundColor: TColors.secondary.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm,
                          vertical: TSizes.xs,
                        ),
                        child: Text(
                          '${productData['discount']}% Off',
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
                  productData['description'] ?? 'No description available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Add to Cart Button
                ElevatedButton(
                  onPressed: () {
                    // Handle add to cart functionality
                    print('Product added to cart');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: TSizes.defaultSpace),
                    backgroundColor: TColors.dark,
                  ),
                  child: const Text(
                    'Add to Wishlist',
                    style: TextStyle(color: TColors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle add to Wishlist functionality
                    print('Product added to Wishlist');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: TSizes.defaultSpace),
                    backgroundColor: TColors.dark,
                  ),
                  child: const Text(
                    'Add to Wishlist',
                    style: TextStyle(color: TColors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
