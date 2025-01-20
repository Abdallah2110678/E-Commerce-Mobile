import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/controllers/CartController.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/controllers/home_controller.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/home/section_heading.dart';
import 'package:mobile_project/widgets/images/circular_image.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/products/product_cards/RatingsDetailsPage.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';
import 'package:mobile_project/widgets/texts/product_price_text.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:get/get.dart';
class ProductDescriptionPage extends ConsumerWidget {
  final Product product;
  final bool action;

  ProductDescriptionPage({
    super.key,
    required this.product,
    this.action = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = THelperFunctions.isDarkMode(context);
    final user = AuthenticationRepository.instance.authUser;
    final userController = UserController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: dark ? TColors.black : TColors.grey,
        elevation: 0,
        iconTheme: IconThemeData(color: dark ? TColors.white : TColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            Center(
              child: TRoundedImage(
                isNetworkImage: true,
                imageUrl: product.thumbnailUrl,
                height: 250,
                applyImageRadius: true,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Product Title and Brand
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.sm),
            Row(
              children: [
                TCircularImage(
                  isNetworkImage: true,
                  image: product.brand.logoUrl,
                  backgroundColor: Colors.transparent,
                  overlayColor: THelperFunctions.isDarkMode(context)
                      ? TColors.white
                      : TColors.black,
                ),
                TBrandTitleWithVerifiedIcon(
                  title: product.brand.name,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Row(
              children: [
                TCircularImage(
                  isNetworkImage: true,
                  image: product.category.imagUrl,
                  backgroundColor: Colors.transparent,
                  overlayColor: THelperFunctions.isDarkMode(context)
                      ? TColors.white
                      : TColors.black,
                ),
                TBrandTitleWithVerifiedIcon(
                  title: product.category.name,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Product Price and Discount
            Row(
              children: [
                if (product.discount > 0)
                  TProductPriceText(
                    isLarge: true,
                    price: product.discountedPrice.toStringAsFixed(2),
                  ),
                SizedBox(
                  width: 15,
                ),
                TProductPriceText(
                  isLarge: product.discount > 0 ? false : true,
                  lineThrough: product.discount > 0 ? true : false,
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
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'stock:    ${product.stock}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// Product Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(height: 8),
// Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    StarRating(
                      rating: product.averageRating,
                      starSize: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.ratingComments.length} reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RatingsDetailsPage(product: product),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: TColors.primary),
                  ),
                ),
              ],
            ),

            /// Add to Cart Button
            if (action == true)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Product added to cart')),
                        );
                      },
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(color: TColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.buttonElevation),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddRatingCommentScreen(
                              productId: product.id,
                              userId: user?.uid.toString() ?? '',
                              userName: userController.user.value.fullName,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Add Rating & Comment',
                        style: TextStyle(color: TColors.white),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: TSizes.spaceBtwSections),
            TSectionHeading(
              title: 'Ratings & Reviews',
              showActionButton: false,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ...product.ratingComments.map((rc) {
              return Card(
                margin: const EdgeInsets.only(bottom: TSizes.sm),
                child: ListTile(
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
                    DateFormat('(hh-mm)dd MMM yyyy').format(rc.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }).toList(),

            /// Add Rating & Comment Button
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating; // The average rating value (e.g., 4.5)
  final double starSize; // Size of the stars
  final Color starColor; // Color of the stars

  const StarRating({
    required this.rating,
    this.starSize = 24.0,
    this.starColor = Colors.amber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        // Calculate if the current star should be fully filled, half-filled, or empty
        if (index < rating && index + 1 > rating) {
          // Half-filled star
          return Icon(
            Icons.star_half,
            size: starSize,
            color: starColor,
          );
        } else if (index < rating) {
          // Fully filled star
          return Icon(
            Icons.star,
            size: starSize,
            color: starColor,
          );
        } else {
          // Empty star
          return Icon(
            Icons.star_border,
            size: starSize,
            color: starColor,
          );
        }
      }),
    );
  }
}

class AddRatingCommentScreen extends StatelessWidget {
  final String productId;
  final String userId;
  final String userName;

  AddRatingCommentScreen({
    required this.productId,
    required this.userId,
    required this.userName,
  });

  final HomeController _productController = Get.put(HomeController());

  final TextEditingController _commentController = TextEditingController();
  final RxInt _selectedRating = 0.obs; // Observable for selected rating

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Rating & Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Star Rating Widget
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _selectedRating.value
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () {
                        _selectedRating.value = index + 1; // Update rating
                      },
                    );
                  }),
                )),
            SizedBox(height: 16),
            // Comment Field
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment',
                hintText: 'Enter your comment',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            // Submit Button
            ElevatedButton(
              onPressed: () async {
                if (_selectedRating.value == 0) {
                  Get.snackbar('Error', 'Please select a rating');
                  return;
                }

                if (_commentController.text.isEmpty) {
                  Get.snackbar('Error', 'Comment cannot be empty');
                  return;
                }

                // Check if the user has already rated this product
                bool hasRated = await _productController.hasUserRated(
                  productId: productId,
                  userId: userId,
                );

                if (hasRated) {
                  Get.snackbar('Error', 'You have already rated this product');
                  return;
                }

                // Add the rating and comment
                await _productController.addRatingComment(
                  productId: productId,
                  userId: userId,
                  userName: userName,
                  rating: _selectedRating.value.toDouble(),
                  comment: _commentController.text,
                );

                // Clear the form
                _selectedRating.value = 0;
                _commentController.clear();

                Get.snackbar(
                    'Success', 'Rating and comment added successfully');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
