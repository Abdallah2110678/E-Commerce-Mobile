import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/home_controller.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/screens/home/appbar.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/constants/text_strings.dart';
import 'package:mobile_project/utils/device/device_utility.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/images/rounded_image.dart';
import 'package:mobile_project/widgets/layout/grid_layout.dart';
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //header
            const TPrimaryHeaderContainer(
                child: Column(
              children: [
                ///appbar
                THomeAppBar(),
                SizedBox(height: TSizes.spaceBtwSections),

                ///searchbar
                TSearchContainer(text: 'Search in Store'),
                SizedBox(height: TSizes.spaceBtwSections),

                ///categories
                Padding(
                  padding: EdgeInsets.only(left: TSizes.defaultSpace),
                  child: Column(
                    children: [
                      ///heading
                      TSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white),
                      SizedBox(height: TSizes.spaceBtwSections),

                      //categories
                      THomeCategories(),
                    ],
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwSections),
              ],
            )),
            Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    const TPromoSlider(banners: TImages.banners),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// -- Popular Products -- Tutorial [Section #3, Video #7]
                    TSectionHeading(
                      title: 'Popular Product',
                      onPressed: () {},
                      showActionButton: true,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TGridLayout(
                      itemCount: 1,
                      itemBuilder: (_, index) => const TProductCardVertical(),
                    ),
                  ],
                ))
          ],
        ),
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
          items: banners.map((url) => TRoundedImage(imageUrl: url,isNetworkImage: true,)).toList(),
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

// class TRoundedImage extends StatelessWidget {
//   const TRoundedImage({
//     super.key,
//     this.border,
//     this.padding,
//     this.onPressed,
//     this.width,
//     this.height,
//     this.applyImageRadius = true,
//     required this.imageUrl,
//     this.fit = BoxFit.contain,
//     this.backgroundColor,
//     this.isNetworkImage = false,
//     this.borderRadius = TSizes.md,
//   });

//   final double? width, height;
//   final String imageUrl;
//   final bool applyImageRadius;
//   final BoxBorder? border;
//   final Color? backgroundColor;
//   final BoxFit fit;
//   final EdgeInsetsGeometry? padding;
//   final bool isNetworkImage;
//   final VoidCallback? onPressed;
//   final double borderRadius;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: width,
//         height: height,
//         padding: padding,
//         decoration: BoxDecoration(
//           border: border,
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(borderRadius),
//         ),
//         child: ClipRRect(
//           borderRadius: applyImageRadius
//               ? BorderRadius.circular(borderRadius)
//               : BorderRadius.zero,
//           child: Image(
//             fit: fit,
//             image: isNetworkImage
//                 ? NetworkImage(imageUrl)
//                 : AssetImage(imageUrl) as ImageProvider,
//           ),
//         ),
//       ),
//     );
//   }
// }

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
                image: category.imagUrl, // Replace with dynamic image handling if needed
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
    this.backgroundColor = TColors.white,
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
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          width: TDeviceUtils.getScreenWidth(context),
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            color: showBackground
                ? dark
                    ? TColors.dark
                    : TColors.light
                : Colors.transparent,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: showBorder ? Border.all(color: TColors.grey) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: TColors.darkGrey),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(text, style: Theme.of(context).textTheme.bodySmall),
            ],
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
class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({super.key, required this.onPressed, this.iconColor});

  final Color? iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.shopping_bag, color: iconColor)),
        Positioned(
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: TColors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text('2',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .apply(color: TColors.white, fontSizeFactor: 0.8)),
            ),
          ),
        )
      ],
    );
  }
}

///home
class THomeAppBar extends StatelessWidget {
  const THomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TAppbar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TTexts.homeAppbarTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .apply(color: TColors.grey)),
          Text(TTexts.homeAppbarSubTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .apply(color: TColors.white)),
        ],
      ),
      actions: [
        //cart
        TCartCounterIcon(onPressed: () {}, iconColor: TColors.white),
      ],
    );
  }
}
