import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/device/device_utility.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';

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
