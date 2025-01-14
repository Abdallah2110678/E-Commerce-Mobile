import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/CartController.dart';

import 'package:mobile_project/controllers/home_controller.dart';
import 'package:mobile_project/controllers/store_controller.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/models/role.dart';
import 'package:mobile_project/screens/All_product/All_Product%20_Screen.dart';
import 'package:mobile_project/screens/Cart/Cart_Screen.dart';

import 'package:mobile_project/screens/chat/Admin_List.dart';
import 'package:mobile_project/screens/chat/Chat_Screen.dart';
import 'package:mobile_project/screens/home/appbar.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/constants/text_strings.dart';
import 'package:mobile_project/utils/device/device_utility.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/utils/shimmers/shimmer.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final StoreController _storeController = Get.find<StoreController>();
  Future<String?> _getAdminEmail() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Role', isEqualTo: 'admin')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('Email');
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching admin email: $e');
      return null;
    }
  }

  Future<Role> _getUserRole(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final role = snapshot.docs.first['Role'] as String?;
        if (role == 'admin') {
          return Role.admin;
        }
      }
      return Role.user;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return Role.user;
    }
  }

  void _navigateToChat(BuildContext context, String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email.')),
      );
      return;
    }

    final role = await _getUserRole(email);

    if (role == Role.admin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserListScreen(
            onUserSelected: (userEmail) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUserEmail: email,
                    targetEmail: userEmail,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      final adminEmail = await _getAdminEmail();
      if (adminEmail != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserEmail: email,
              targetEmail: adminEmail,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No admin available for chat.')),
        );
      }
    }
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      final productsSnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final categoriesSnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final brandsSnapshot =
          await FirebaseFirestore.instance.collection('brands').get();

      final categoryMap = {
        for (var doc in categoriesSnapshot.docs)
          doc.id: Category.fromFirestore(doc)
      };
      final brandMap = {
        for (var doc in brandsSnapshot.docs) doc.id: Brand.fromFirestore(doc)
      };

      return productsSnapshot.docs.map((doc) {
        final category = categoryMap[doc['categoryId']]!;
        final brand = brandMap[doc['brandId']]!;
        return Product.fromFirestore(doc, category: category, brand: brand);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final controller = UserController.instance;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                  TSearchContainer(text: 'Search in Store'),
                  SizedBox(height: TSizes.spaceBtwSections),
                  Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        TSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: TSizes.spaceBtwSections),
                        THomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const TPromoSlider(banners: TImages.banners),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  FutureBuilder<List<Product>>(
                    future: _fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final products = snapshot.data ?? [];
                      return Column(
                        children: [
                          TSectionHeading(
                            title: 'Popular Products',
                            onPressed: () {
                              // Navigate to AllProductsScreen with the fetched products
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllProductsScreen(
                                    products: products,
                                  ),
                                ),
                              );
                            },
                            showActionButton: true,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: TSizes.sm,
                              mainAxisSpacing: TSizes.sm,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return TProductCardVertical(
                                  product: products[index]);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToChat(context, controller.user.value.email),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}

class TPromoSlider extends StatelessWidget {
  const TPromoSlider({
    super.key,
    required this.banners,
  });

  final List<String> banners;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Column(
      children: [
        CarouselSlider(
          items: banners
              .map((url) => TRoundedImage(
                    imageUrl: url,
                    isNetworkImage: true,
                  ))
              .toList(),
          options: CarouselOptions(
              viewportFraction: 1,
              onPageChanged: (index, _) =>
                  controller.updatePageIndicator(index)),
        ),
        const SizedBox(
          height: TSizes.spaceBtwItems,
        ),
        Center(
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banners.length; i++)
                  TCircularContainer(
                    width: 20,
                    height: 4,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor: controller.carousalCurrentIndex.value == i
                        ? Colors.green
                        : Colors.grey,
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}

//home category
class THomeCategories extends StatelessWidget {
  const THomeCategories({super.key});

  Future<List<Category>> _fetchCategories() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return querySnapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading categories'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final categories = snapshot.data!;

        return SizedBox(
          height: 90,
          child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final category = categories[index];
              return TVerticalImageText(
                image: category
                    .imagUrl, // Replace with dynamic image handling if needed
                title: category.name,
                onTap: () {
                  // Handle category tap
                  print('Selected category: ${category.name}');
                },
              );
            },
          ),
        );
      },
    );
  }
}

//image category
class TVerticalImageText extends StatelessWidget {
  const TVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = TColors.white,
    this.backgroundColor,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //circular icon
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: backgroundColor ?? (dark ? TColors.dark : TColors.white),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Image(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    color: dark ? TColors.light : TColors.dark),
              ),
            ),
            //text
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            SizedBox(
              width: 55,
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .apply(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//category heading
class TSectionHeading extends StatelessWidget {
  const TSectionHeading({
    super.key,
    this.textColor,
    this.showActionButton = true,
    required this.title,
    this.buttonTitle = 'View all',
    this.onPressed,
  });

  final Color? textColor;
  final bool showActionButton;
  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (showActionButton)
          TextButton(onPressed: onPressed, child: Text(buttonTitle))
      ],
    );
  }
}

//searchbar
class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
    this.onChanged,
    this.controller,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Padding(
      padding: padding,
      child: Container(
        width: TDeviceUtils.getScreenWidth(context),
        decoration: BoxDecoration(
          color: showBackground
              ? dark
                  ? Colors.grey[800]
                  : Colors.grey[200]
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          border: showBorder && !showBackground
              ? Border.all(color: TColors.grey)
              : null,
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: text,
            hintStyle: TextStyle(
              color: dark ? Colors.white54 : Colors.black54,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: dark ? Colors.white54 : Colors.black54,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: TSizes.md,
              vertical: TSizes.sm,
            ),
          ),
          style: TextStyle(
            color: dark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

///circular container
class TCircularContainer extends StatelessWidget {
  const TCircularContainer(
      {super.key,
      this.width = 400,
      this.height = 400,
      this.radius = 400,
      this.margin,
      this.padding = 0,
      this.child,
      this.backgroundColor = TColors.white});

  final double? width;
  final double? height;
  final double radius;
  final double padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}

///curve edget
class TCustomCurvedEdges extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    final firstCurve = Offset(0, size.height - 20);
    final lastCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(
        firstCurve.dx, firstCurve.dy, lastCurve.dx, lastCurve.dy);

    final secondFirstCurve = Offset(0, size.height - 20);
    final secondLastCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(secondFirstCurve.dx, secondFirstCurve.dy,
        secondLastCurve.dx, secondLastCurve.dy);

    final thirdFirstCurve = Offset(size.width, size.height - 20);
    final thirdLastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(thirdFirstCurve.dx, thirdFirstCurve.dy,
        thirdLastCurve.dx, thirdLastCurve.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

///widge curve edged
class TCurvedEdgeWidget extends StatelessWidget {
  const TCurvedEdgeWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TCustomCurvedEdges(),
      child: child,
    );
  }
}

///header container
class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgeWidget(
      child: Container(
        color: TColors.primary,
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -250,
              child: TCircularContainer(
                  backgroundColor: TColors.textWhite.withOpacity(0.1)),
            ),
            Positioned(
              top: 100,
              right: -300,
              child: TCircularContainer(
                  backgroundColor: TColors.textWhite.withOpacity(0.1)),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

///cart

class TCartCounterIcon extends ConsumerWidget {
  const TCartCounterIcon({super.key, required this.onPressed, this.iconColor});

  final Color? iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      color: TColors.white, // Text color
                      fontSizeFactor: 0.8, // Adjust font size
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///home

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController()); // Initialize UserController

    return TAppbar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.homeAppbarTitle,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: TColors.grey),
          ),
          Obx(() {
            if (controller.profileLoading.value) {
              return const TShimmerEffect(
                  width: 80, height: 15); // Show shimmer effect while loading
            } else {
              return Text(
                controller.user.value.fullName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .apply(color: TColors.white),
              );
            }
          }),
        ],
      ),
      actions: [
        // Cart Icon with Counter
        TCartCounterIcon(
          onPressed: () {
            // Navigate to cart screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          iconColor: TColors.white,
        ),
      ],
    );
  }
}
