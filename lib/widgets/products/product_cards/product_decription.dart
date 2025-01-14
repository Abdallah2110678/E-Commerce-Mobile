import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // Fetch the category details
    final categoryDoc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(productData['categoryId'])
        .get();

    final categoryData = categoryDoc.exists ? categoryDoc.data() : null;

    return {
      'product': productData,
      'brand': brandData,
      'category': categoryData,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: dark ? TColors.black : TColors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!['product'];
          final brandData = snapshot.data!['brand'];
          final categoryData = snapshot.data!['category'];

          // Create Product, Brand, and Category objects
          final brand = Brand(
            id: productData['brandId'],
            name: brandData?['name'] ?? 'Unknown Brand',
            logoUrl: brandData?['logoUrl'] ?? '',
          );

          final category = Category(
            id: productData['categoryId'],
            name: categoryData?['name'] ?? 'Unknown Category',
            imagUrl: categoryData?['imagUrl'] ?? '',
          );

          final product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            thumbnailUrl: productData['thumbnailUrl'],
            imageUrls: List<String>.from(productData['imageUrls'] ?? []),
            price: (productData['price'] as num).toDouble(),
            discount: (productData['discount'] as num).toDouble(),
            stock: (productData['stock'] as num).toInt(),
            category: category,
            brand: brand,
          );

          return Padding(
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
                      title: brand.name,
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
              ],
            ),
          );
        },
      ),
    );
  }
}