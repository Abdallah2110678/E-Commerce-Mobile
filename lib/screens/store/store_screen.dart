import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/screens/home/appbar.dart';
import 'package:mobile_project/screens/home/home.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/enum.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/images/circular_image.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchFeaturedBrands() async {
    final brandsSnapshot =
        await FirebaseFirestore.instance.collection('brands').get();

    // Retrieve brands with product counts
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
        actions: [
          TCartCounterIcon(onPressed: () {}),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              floating: true,
              backgroundColor: THelperFunctions.isDarkMode(context)
                  ? TColors.black
                  : TColors.white,
              expandedHeight: 440,
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchFeaturedBrands(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading brands'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No featured brands'));
                    }

                    final brands = snapshot.data!;

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        /// -- Search bar
                        const SizedBox(height: TSizes.spaceBtwItems),
                        const TSearchContainer(
                          text: 'Search in Store',
                          showBorder: true,
                          showBackground: false,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        /// -- Featured Brands
                        TSectionHeading(
                          title: 'Featured Brands',
                          onPressed: () {},
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

                        TGridLayout(
                          itemCount: brands.length,
                          mainAxisExtent: 80,
                          itemBuilder: (_, index) {
                            final brand = brands[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to brand-specific product list
                                print('Selected brand: ${brand['name']}');
                              },
                              child: TRoundedContainer(
                                padding: const EdgeInsets.all(TSizes.sm),
                                showBorder: true,
                                backgroundColor: Colors.transparent,
                                child: Row(
                                  children: [
                                    /// -- Brand Logo
                                    Flexible(
                                      child: TCircularImage(
                                        isNetworkImage: true,
                                        image: brand['logoUrl'],
                                        backgroundColor: Colors.transparent,
                                        overlayColor:
                                            THelperFunctions.isDarkMode(
                                                    context)
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
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ];
        },
        body: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Additional dynamic content for the store can go here
          ],
        ),
      ),
    );
  }
}
