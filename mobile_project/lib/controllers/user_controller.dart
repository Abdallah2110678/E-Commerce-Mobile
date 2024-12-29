import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/authentication.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/screens/home/profile/re_Authenticate_user_login_form.dart';
import 'package:mobile_project/screens/login/login.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/network_manager.dart';
import 'package:mobile_project/utils/popups/full_screen_loader.dart';
import 'package:mobile_project/utils/popups/loaders.dart';
import 'package:provider/provider.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  var users = <UserModel>[].obs; // Reactive list

  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());
  final profileLoading = false.obs;

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userrepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
      profileLoading.value = false;
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  // Load users from repository
  Future<void> loadUsers() async {
    try {
      users.value = await userRepository.getUsers();
    } catch (e) {
      print("Error loading users in UserController: $e");
    }
  }

  // Add user
  Future<void> addUser(UserModel user) async {
    await userRepository.addUser(user);
    await loadUsers(); // Reload users after adding
  }

  // Update user
  // Future<void> updateUser(UserModel user) async {
  //   await userRepository.updateUser(user);
  //   await loadUsers(); // Reload users after updating
  // }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await userRepository.deleteUser(userId);
    await loadUsers(); // Reload users after deleting
  }

  //save user records from any registeration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null) {
        //convert name to first and last name
        final nameparts =
            UserModel.nameParts(userCredentials.user!.displayName ?? '');
        final username =
            UserModel.generateUsername(userCredentials.user!.displayName ?? '');

        final user = UserModel(
            id: userCredentials.user!.uid,
            username: username,
            email: userCredentials.user!.email ?? '',
            firstName: nameparts[0],
            lastName:
                nameparts.length > 1 ? nameparts.sublist(1).join('') : ' ',
            phoneNumber: userCredentials.user!.phoneNumber ?? '',
            profilePicture: userCredentials.user!.photoURL ?? '');

        //save user data
        await userRepository.saveUserRecords(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
          title: 'Data Not Saved',
          message:
              'Something Went Wrong While Saving your Information. You Can re-save your data in your profile');
    }
  }

  ///delete Account warrning
  void deleteAccountWarrningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText:
          'Are you sure you want to delete your account? This action is not reversible and all of your data will be lost',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            side: const BorderSide(color: Colors.red)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
          onPressed: () => Navigator.of(Get.overlayContext!).pop(),
          child: const Text('Cancel')),
    );
  }

  ///delete user account
  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Processing...', TImages.docerAnimation);

      ///first re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider =
          auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
        //Re verify auth email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAll(() => const LoginScreen());
        } else if (provider == 'password') {
          TFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthenticateUserLoginForm());
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// -- RE-AUTHENTICATE before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog('Processing', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );

      await AuthenticationRepository.instance.deleteAccount();

      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
