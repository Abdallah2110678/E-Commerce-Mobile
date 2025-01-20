import 'package:flutter/material.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';

class ProductTitle extends StatelessWidget {
  final Product product;
  final bool darkMode;

  const ProductTitle({
    Key? key,
    required this.product,
    required this.darkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      product.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: darkMode ? TColors.white : TColors.dark,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}