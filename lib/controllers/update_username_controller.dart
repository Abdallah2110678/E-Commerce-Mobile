import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/screens/home/profile/profile.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';
import 'package:mobile_project/models/usermodel.dart';

class UpdateUsernameController extends GetxController {
  static UpdateUsernameController get instance => Get.find();

  // Variables
  final username = TextEditingController();
  GlobalKey<FormState> updateUsernameFormKey = GlobalKey<FormState>();
  final userController = UserController.instance;

  @override
  void onInit() {
    super.onInit();
    // Initialize with current username
    username.text = userController.user.value.username;
  }

  // Update Username
  Future<void> updateUsername() async {
    try {
      //start loading
      TFullScreenLoader.openLoadingDialog(
          'We are updating your Information...', TImages.docerAnimation);

      ///check internet
      final isConnect = await NetworkManager.instance.isConnected();
      if (!isConnect) {
        TFullScreenLoader.stopLoading();
        return;
      }

      ///form validation
      if (!updateUsernameFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.',
        );
        return;
      }

      // Get current user data
      final currentUser = userController.user.value;

      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        username: username.text.trim(),
        email: currentUser.email,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        phoneNumber: currentUser.phoneNumber,
        profilePicture: currentUser.profilePicture,
        role: currentUser.role,
      );

      // Save to Firebase
      await userController.updateUser(user: updatedUser);

      // Refresh user data
      await userController.fetchUserRecord();

      // Hide loading indicator
      TFullScreenLoader.stopLoading();

      // Navigate back
      Get.off(() => const ProfileScreen());
    } catch (e) {
      // Hide loading indicator
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  @override
  void dispose() {
    username.dispose();
    super.dispose();
  }
}
