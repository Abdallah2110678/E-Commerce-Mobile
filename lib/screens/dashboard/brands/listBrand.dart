
import 'package:flutter/material.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/enum.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/images/circular_image.dart';
import 'package:mobile_project/widgets/texts/brand_title_text_with_varified_icon.dart';

class ListBrandScreen extends StatelessWidget {
  const ListBrandScreen({
    super.key,
    required this.brand,
  });

  final Map<String, dynamic> brand;

  @override
  Widget build(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            /// -- Brand Logo
            Flexible(
              child: TCircularImage(
                isNetworkImage: true,
                image: brand['logoUrl'],
                backgroundColor: Colors.transparent,
                overlayColor: THelperFunctions.isDarkMode(context)
                    ? TColors.white
                    : TColors.black,
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems / 2),

            /// -- Brand Name and Product Count
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TBrandTitleWithVerifiedIcon(
                    title: brand['name'],
                    brandTextSize: TextSizes.large,
                  ),
                  Text(
                    '${brand['productCount']} products',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}