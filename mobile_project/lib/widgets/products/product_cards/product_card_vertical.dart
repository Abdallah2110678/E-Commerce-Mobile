import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/screens/styles/shadows.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/products/product_cards/product_decription.dart';
import 'package:mobile_project/widgets/texts/product_price_text.dart';
import 'package:mobile_project/widgets/texts/product_title_text.dart';
import 'package:mobile_project/widgets/icons/circular_icon.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key});

  Future<List<Product>> _fetchProducts() async {
    // Fetch products from Firestore
    final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();

    // Fetch categories and brands simultaneously
    final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
    final brandsSnapshot = await FirebaseFirestore.instance.collection('brands').get();

    // Map categories and brands by ID for lookup
    final categoryMap = {
      for (var doc in categoriesSnapshot.docs)
        doc.id: Category.fromFirestore(doc)
    };
    final brandMap = {
      for (var doc in brandsSnapshot.docs) doc.id: Brand.fromFirestore(doc)
    };

    // Parse products and associate categories and brands
    return productsSnapshot.docs.map((doc) {
      final category = categoryMap[doc['categoryId']]!;
      final brand = brandMap[doc['brandId']]!;
      return Product.fromFirestore(doc, category: category, brand: brand);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading products'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        final products = snapshot.data!;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
           
                // Handle product tap
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
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  boxShadow: [TShadowStyle.verticalProductShadow],
                  borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                  color: THelperFunctions.isDarkMode(context)
                      ? TColors.darkerGrey
                      : TColors.white,
                ),
                child: Column(
                  children: [
                    /// Thumbnail, Wishlist Button, Discount Tag
                    TRoundedContainer(
                      height: 180,
                      padding: const EdgeInsets.all(TSizes.sm),
                      backgroundColor: THelperFunctions.isDarkMode(context)
                          ? TColors.dark
                          : TColors.light,
                      child: Stack(
                        children: [
                          /// Thumbnail Image
                          TRoundedImage(
                            isNetworkImage: true,
                            imageUrl: product.thumbnailUrl,
                            applyImageRadius: true,
                          ),

                          /// Sale Tag
                          if (product.discount > 0)
                            Positioned(
                              top: 12,
                              child: TRoundedContainer(
                                radius: TSizes.sm,
                                backgroundColor: TColors.secondary.withOpacity(0.8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TSizes.sm,
                                  vertical: TSizes.xs,
                                ),
                                child: Text(
                                  '${product.discount}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .apply(color: TColors.black),
                                ),
                              ),
                            ),

                          /// Wishlist Button
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: TCircularIcon(
                              icon: Iconsax.heart5,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),

                    /// Title and Brand
                    Padding(
                      padding: const EdgeInsets.only(left: TSizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Product Title
                          TProductTitleText(
                            title: product.title,
                            smallSize: true,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),

                          /// Brand Information
                          Row(
                            children: [
                              /// Brand Logo
                              if (product.brand.logoUrl.isNotEmpty)
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(product.brand.logoUrl),
                                  radius: TSizes.iconSm,
                                ),
                              const SizedBox(width: TSizes.sm),

                              /// Brand Name
                              Text(
                                product.brand.name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    /// Price and Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Price
                        Padding(
                          padding: const EdgeInsets.only(left: TSizes.sm),
                          child: TProductPriceText(
                            price: product.discountedPrice.toStringAsFixed(2),
                          ),
                        ),

                        /// Add Button
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
                            width: TSizes.iconLg * 1.2,
                            height: TSizes.iconLg * 1.2,
                            child: Center(
                              child: Icon(
                                Iconsax.add,
                                color: TColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
