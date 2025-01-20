import 'package:flutter/material.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';

class ProductBrand extends StatelessWidget {
  final Product product;
  final bool darkMode;

  const ProductBrand({
    Key? key,
    required this.product,
    required this.darkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (product.brand.logoUrl.isNotEmpty) ...[
          CircleAvatar(
            backgroundImage: NetworkImage(product.brand.logoUrl),
            radius: TSizes.iconXs,
          ),
          const SizedBox(width: TSizes.xs),
        ],
        Expanded(
          child: Text(
            product.brand.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: darkMode ? TColors.white : TColors.dark,
                ),
          ),
        ),
      ],
    );
  }
}
