import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/screens/home/profile/profile.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';
import 'package:mobile_project/controllers/authentication.dart';

class UpdatePasswordController extends GetxController {
  static UpdatePasswordController get instance => Get.find();

  // Variables
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  GlobalKey<FormState> updatePasswordFormKey = GlobalKey<FormState>();
  final hidePassword = true.obs;
  final hideNewPassword = true.obs;
  final hideConfirmPassword = true.obs;
  final authRepository = AuthenticationRepository.instance;

  // Update Password
  Future<void> updatePassword() async {
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
      if (!updatePasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check if passwords match
      if (newPassword.text.trim() != confirmPassword.text.trim()) {
        TLoaders.warningSnackBar(
          title: 'Password Mismatch',
          message: 'New password and confirm password do not match.',
        );
        return;
      }

      // First re-authenticate user with old password
      await authRepository.reAuthenticateEmailAndPassword(
        authRepository.authUser!.email!,
        oldPassword.text.trim(),
      );

      // If re-authentication successful, update password
      await authRepository.updatePassword(newPassword.text.trim());

      // Show success message
      TLoaders.successSnackBar(
        title: 'Password Updated',
        message: 'Your password has been updated successfully.',
      );

      // Clear the form
      oldPassword.clear();
      newPassword.clear();
      confirmPassword.clear();

      //Move to previous screen
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Snap!....', message: e.toString());
    }
  }

  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }
}
