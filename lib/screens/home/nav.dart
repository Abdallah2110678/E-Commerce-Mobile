import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/nav_controller.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/models/role.dart';

class Nav extends StatelessWidget {
  const Nav({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavController());
    final dark = THelperFunctions.isDarkMode(context);
    final userController = Get.find<UserController>();

    return Scaffold(
      bottomNavigationBar: Obx(
        () {
          // Check the user's role and adjust the navigation items accordingly
          var userRole = userController.user.value.role;
          var destinations = userRole == Role.admin
              ? const [
                  NavigationDestination(
                      icon: Icon(Iconsax.home), label: 'Home'),
                  NavigationDestination(
                      icon: Icon(Iconsax.shop), label: 'Store'),
                  NavigationDestination(
                      icon: Icon(Iconsax.user), label: 'Dashboard'),
                  NavigationDestination(
                      icon: Icon(Iconsax.user), label: 'Profile'),
                ]
              : const [
                  NavigationDestination(
                      icon: Icon(Iconsax.home), label: 'Home'),
                  NavigationDestination(
                      icon: Icon(Iconsax.shop), label: 'Store'),
                  NavigationDestination(
                      icon: Icon(Iconsax.heart), label: 'Wishlist'),
                  NavigationDestination(
                      icon: Icon(Iconsax.user), label: 'Profile'),
                ];

          return NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: controller.selectIndex.value,
            onDestinationSelected: (index) =>
                controller.selectIndex.value = index,
            backgroundColor: dark ? TColors.black : Colors.white,
            indicatorColor: dark
                ? TColors.white.withOpacity(0.1)
                : TColors.black.withOpacity(0.1),
            destinations: destinations,
          );
        },
      ),
      body: Obx(() => controller.screens[controller.selectIndex.value]),
    );
  }
}
