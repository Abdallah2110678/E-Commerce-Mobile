import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/device/device_utility.dart';

class TAppbar extends StatelessWidget implements PreferredSizeWidget {
  const TAppbar({
    super.key,
    this.title,
    this.showBlackArrow = true,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
  });

  final Widget? title;
  final bool showBlackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    // Determine the icon color based on the theme (dark or light mode)
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // Use white for dark mode
        : Colors.black; // Use black for light mode

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: showBlackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Iconsax.arrow_left,
                    color: iconColor), // Set icon color
              )
            : leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(leadingIcon, color: iconColor), // Set icon color
                  )
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
