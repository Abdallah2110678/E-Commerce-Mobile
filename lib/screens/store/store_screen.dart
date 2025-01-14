import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/controllers/store_controller.dart'; // Import StoreController
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

  final StoreController _storeController = Get.find<StoreController>();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

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
              /// -- Search Bar
              const SizedBox(height: TSizes.spaceBtwItems),
              TSearchContainer(
                text: 'Search in Store',
                showBorder: true,
                showBackground: false,
                padding: EdgeInsets.zero,
                onChanged: (value) {
                  _searchQuery.value = value; // Update search query
                },
                controller: _searchController,
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
                future: _storeController.fetchFeaturedBrands(),
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
                                _storeController.selectBrand(
                                    brand['id'], brand['name']);
                              },
                              child: TRoundedContainer(
                                padding: const EdgeInsets.all(TSizes.sm),
                                showBorder: true,
                                backgroundColor:
                                    _storeController.selectedBrandId.value ==
                                            brand['id']
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
                        if (_storeController.selectedBrandId.value.isEmpty &&
                            _searchQuery.value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            const SizedBox(height: TSizes.spaceBtwSections),
                            TSectionHeading(
                              title: _searchQuery.value.isNotEmpty
                                  ? 'Search Results'
                                  : '${_storeController.selectedBrandName.value} Products',
                              onPressed: () {},
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            StreamBuilder<QuerySnapshot>(
                              stream: _searchQuery.value.isNotEmpty
                                  ? _storeController
                                      .searchProducts(_searchQuery.value)
                                  : _storeController.fetchProductsByBrand(
                                      _storeController.selectedBrandId.value),
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
                                      child: Text('No products found'),
                                    ),
                                  );
                                }

                                // Convert Firestore documents to Product objects
                                final products = snapshot.data!.docs.map((doc) {
                                  return _storeController
                                      .productFromSnapshot(doc);
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
