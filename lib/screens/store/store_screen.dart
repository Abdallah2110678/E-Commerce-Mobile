import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart'; // Import Product model
import 'package:mobile_project/models/brand.dart'; // Import Brand model
import 'package:mobile_project/screens/home/appbar.dart';
import 'package:mobile_project/screens/home/home.dart';
import 'package:mobile_project/utils/constants/enum.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart';
import 'package:mobile_project/widgets/images/circular_image.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';

class StoreScreen extends StatelessWidget {
  StoreScreen({super.key});

  final RxString selectedBrandId = ''.obs;
  final RxString selectedBrandName = ''.obs;

  // Fetch featured brands from Firestore
  Future<List<Map<String, dynamic>>> _fetchFeaturedBrands() async {
    final brandsSnapshot =
        await FirebaseFirestore.instance.collection('brands').get();

    final featuredBrands = await Future.wait(
      brandsSnapshot.docs.map((doc) async {
        final brandId = doc.id;
        final productCount = await FirebaseFirestore.instance
            .collection('products')
            .where('brandId', isEqualTo: brandId)
            .get()
            .then((snapshot) => snapshot.docs.length);

        return {
          'id': brandId,
          'name': doc['name'],
          'logoUrl': doc['logoUrl'],
          'productCount': productCount,
        };
      }),
    );

    return featuredBrands;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(
        title: Text('Store', style: Theme.of(context).textTheme.headlineMedium),
        actions: const [
          // Add a cart icon or other actions if needed
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// -- Search bar (if needed)
              const SizedBox(height: TSizes.spaceBtwItems),
              const TSearchContainer(
                text: 'Search in Store',
                showBorder: true,
                showBackground: false,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Featured Brands Section
              TSectionHeading(
                title: 'Featured Brands',
                onPressed: () {},
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 1.5),

              // Brands Grid
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchFeaturedBrands(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No featured brands'));
                  }

                  final brands = snapshot.data!;

                  return Column(
                    children: [
                      TGridLayout(
                        itemCount: brands.length,
                        mainAxisExtent: 80,
                        itemBuilder: (_, index) {
                          final brand = brands[index];
                          return Obx(
                            () => GestureDetector(
                              onTap: () {
                                if (selectedBrandId.value == brand['id']) {
                                  selectedBrandId.value = '';
                                  selectedBrandName.value = '';
                                } else {
                                  selectedBrandId.value = brand['id'];
                                  selectedBrandName.value = brand['name'];
                                }
                              },
                              child: TRoundedContainer(
                                padding: const EdgeInsets.all(TSizes.sm),
                                showBorder: true,
                                backgroundColor:
                                    selectedBrandId.value == brand['id']
                                        ? TColors.primary.withOpacity(0.1)
                                        : Colors.transparent,
                                child: Row(
                                  children: [
                                    /// -- Brand Logo
                                    Flexible(
                                      child: TCircularImage(
                                        isNetworkImage: true,
                                        image: brand['logoUrl'],
                                        backgroundColor: Colors.transparent,
                                        overlayColor:
                                            THelperFunctions.isDarkMode(context)
                                                ? TColors.white
                                                : TColors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: TSizes.spaceBtwItems / 2),

                                    /// -- Brand Name and Product Count
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TBrandTitleWithVerifiedIcon(
                                            title: brand['name'],
                                            brandTextSize: TextSizes.large,
                                          ),
                                          Text(
                                            '${brand['productCount']} products',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      /// -- Products Section
                      Obx(() {
                        if (selectedBrandId.value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            const SizedBox(height: TSizes.spaceBtwSections),
                            TSectionHeading(
                              title: '${selectedBrandName.value} Products',
                              onPressed: () {},
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('products')
                                  .where('brandId',
                                      isEqualTo: selectedBrandId.value)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(TSizes.defaultSpace),
                                      child: Text(
                                          'No products found for this brand'),
                                    ),
                                  );
                                }

                                // Convert Firestore documents to Product objects
                                final products = snapshot.data!.docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return Product(
                                    id: doc.id,
                                    title: data['title'] ?? 'Unnamed Product',
                                    description: data['description'] ?? '',
                                    thumbnailUrl: data['thumbnailUrl'] ?? '',
                                    imageUrls: List<String>.from(
                                        data['imageUrls'] ?? []),
                                    price: (data['price'] ?? 0.0).toDouble(),
                                    discount:
                                        (data['discount'] ?? 0.0).toDouble(),
                                    stock: (data['stock'] ?? 0).toInt(),
                                    category: Category(
                                      id: data['categoryId'] ?? '',
                                      name: data['categoryName'] ?? '',
                                      imagUrl: data['categoryImageUrl'] ?? '',
                                    ),
                                    brand: Brand(
                                      id: data['brandId'] ?? '',
                                      name: data['brandName'] ?? '',
                                      logoUrl: data['brandLogoUrl'] ?? '',
                                    ),
                                  );
                                }).toList();

                                // Display products using TGridLayout and TProductCardVertical
                                return TGridLayout(
                                  itemCount: products.length,
                                  itemBuilder: (_, index) =>
                                      TProductCardVertical(
                                    product: products[index],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
