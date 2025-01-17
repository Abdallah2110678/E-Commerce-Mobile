import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/screens/home/profile/profile.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';

class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFromKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeUser();
    super.onInit();
  }

  ///fetch user record
  Future<void> initializeUser() async {
    firstName.text = userController.user.value!.firstName;
    lastName.text = userController.user.value!.lastName;
  }

  Future<void> updateUserName() async {
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
      if (!updateUserNameFromKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      ///update user first & last name
      Map<String, dynamic> name = {
        'FirstName': firstName.text.trim(),
        'LastName': lastName.text.trim(),
      };
      userRepository.update();

      //update RX user value
      userController.user.value!.firstName = firstName.text.trim();
      userController.user.value!.lastName = lastName.text.trim();

      //remove loader
      TFullScreenLoader.stopLoading();

      //show success loader
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your name has been updated');

      //Move to previous screen
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
