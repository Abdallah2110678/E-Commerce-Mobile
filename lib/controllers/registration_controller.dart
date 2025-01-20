import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/screens/navbar/nav.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';
import 'package:mobile_project/models/role.dart';

class RegistrationController extends GetxController {
  static RegistrationController get instance => Get.find();

  // Variables for both login and signup
  final hidePassword = true.obs;
  final email = TextEditingController();
  final password = TextEditingController();

  // Login specific variables
  final rememberMe = false.obs;
  final localStorage = GetStorage();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  // Signup specific variables
  final privacyPolicy = true.obs;
  final lastname = TextEditingController();
  final username = TextEditingController();
  final firstname = TextEditingController();
  final phonenumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    // Initialize remembered login credentials
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  void resetFields() {
    email.clear();
    password.clear();
    lastname.clear();
    username.clear();
    firstname.clear();
    phonenumber.clear();
  }

  // Login Methods
  Future<void> emailAndPasswordSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Logging you in...', TImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
            title: 'No Internet Connection',
            message: 'Please check your internet connection');
        return;
      }

      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      final userCredential = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      final userController = Get.find<UserController>();
      await userController.initializeUser();
      // Check if login was successful
      if (userCredential.user != null) {
        TFullScreenLoader.stopLoading();
        Get.offAll(() => Nav());
      } else {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
            title: 'Error',
            message: 'Login failed. Please check your credentials.');
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    }
  }

  // Signup Methods
  Future<void> signup() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          "We are processing your information", TImages.docerAnimation);

      final isConnect = await NetworkManager.instance.isConnected();
      if (!isConnect) return;

      if (!signupFormKey.currentState!.validate()) return;

      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
            title: 'Accept Privacy Policy',
            message:
                'In order to create account, you must have read and accept the Privacy Policy & Terms of Use');
        return;
      }

      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());

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

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your account has been created!');
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    } finally {
      TFullScreenLoader.stopLoading();
    }
  }

  // Google Sign In
  Future<void> googleSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Logging you in...', TImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final userCredential =
          await AuthenticationRepository.instance.signInWithGoogle();
      await userController.saveUserRecord(userCredential);

      TFullScreenLoader.stopLoading();
      Get.offAll(() => Nav());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    }
  }
}
