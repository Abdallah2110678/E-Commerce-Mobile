import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/screens/drawer.dart';
import 'package:mobile_project/screens/home/home.dart';
import 'package:mobile_project/screens/home/profile/settings.dart';
import 'package:mobile_project/screens/store/store_screen.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/role.dart';
import 'package:mobile_project/screens/wishlist/wishlist.dart';

class NavController extends GetxController {
  final Rx<int> selectIndex = 0.obs;

  // Assuming you have a UserController that holds user info including the role
  final UserController userController = Get.find<UserController>();

  // Define the screens list with role-based conditional logic
  final screens = <Widget>[];

  @override
  void onInit() {
    super.onInit();

    // Check the user role and adjust the screens accordingly
    if (userController.user.value.role == Role.admin) {
      // If the user is an admin, add the Dashboard screen
      screens.addAll([
        HomeScreen(),
        StoreScreen(),
        DrawerScreen(),
        const SettingsScreen(),
      ]);
    } else {
      // If the user is not an admin, exclude the Dashboard screen
      screens.addAll([
        HomeScreen(),
        StoreScreen(),
        const Wishlist(),
        const SettingsScreen(),
      ]);
    }
  }
}
