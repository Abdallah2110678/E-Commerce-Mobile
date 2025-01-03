import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';
import 'package:mobile_project/models/role.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  ///variables
  final hidepassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final lastname = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstname = TextEditingController();
  final phonenumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  ///signup
  void signup() async {
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
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
            title: 'Accept Privacy Policy',
            message:
                'In order to create account, you must have read and accept the Privacy Policy & Terms of Use');
      }

      ///register user in firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());

      ///save data in firebase
      final newUser = UserModel(
        id: userCredential.user!.uid,
        username: username.text.trim(),
        email: email.text.trim(),
        firstName: firstname.text.trim(),
        lastName: lastname.text.trim(),
        phoneNumber: phonenumber.text.trim(),
        profilePicture: '',
        role: Role.user,

      );
      await UserRepository.instance.saveUserRecords(newUser);

      ///remove loader
      TFullScreenLoader.stopLoading();

      ///show success message
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your account has been created!');

      // ///verify email
      // Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      ///error to user
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    } finally {
      ///remove loader
      TFullScreenLoader.stopLoading();
    }
  }
}
