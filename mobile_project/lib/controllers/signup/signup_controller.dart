import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  ///variables
  final hidepassword = true.obs;
  final email = TextEditingController();
  final lastname = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstname = TextEditingController();
  final phonenumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  ///signup
  Future<void> signup() async {
    try {
      ///start loading
      TFullScreenLoader.openLoadingDialog(
          "We are processing yor information", TImages.docerAnimation);

      ///check internet
      final isConnect = await NetworkManager.instance.isConnected();
      if (!isConnect) return;

      ///form validation
      if (!signupFormKey.currentState!.validate()) return;

      ///privacy policy
      ///register user in firebase
      ///save data in firebase
      ///show success message
      ///verify email
    } catch (e) {
      ///error to user
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    } finally {
      ///remove loader
      TFullScreenLoader.stopLoading();
    }
  }
}
