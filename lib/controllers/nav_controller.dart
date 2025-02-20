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

  // Define a reactive list of screens
  final RxList<Widget> screens = <Widget>[].obs;

  @override
  void onInit() {
    super.onInit();
    _updateScreens(userController.user.value?.role ?? Role.user);

    // Watch for changes in the user's role and update the screens dynamically
    ever(userController.user, (user) {
      if (user != null) {
        _updateScreens(user.role);
      }
    });
  }

  void _updateScreens(Role role) {
    screens.clear();
    if (role == Role.admin) {
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
