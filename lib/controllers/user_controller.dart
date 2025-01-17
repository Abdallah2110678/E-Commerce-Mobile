import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:mobile_project/models/role.dart';
import 'package:mobile_project/controllers/authentication.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final AuthenticationRepository _authRepository =
      AuthenticationRepository.instance;

  static UserController get instance => Get.find();
  final _auth = FirebaseAuth.instance;
  var users = <UserModel>[].obs; // Reactive list
  Rx<UserModel> user = UserModel.empty().obs;
  final profileLoading = false.obs;

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  Future<void> initializeUser() async {
    try {
      profileLoading.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User ID not found';

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Update user data in controller
        user.value = UserModel.fromSnapshot(userDoc);
      } else {
        throw 'User document not found';
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
      user.value = UserModel.empty();
    } finally {
      profileLoading.value = false;
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId != null) {
        final userData =
            await _userRepository.fetchUserDetails1(userId: userId);
        user.value = userData; // Update the current user state
      } else {
        clearUser(); // Clear the user if no user is logged in
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user data: $e');
    }
  }

  // Clear the current user data
// In UserController
  void clearUser() {
    user.value = UserModel.empty();
    profileLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await _userRepository.fetchUserDetails();
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
      users.value = await _userRepository.getUsers();
    } catch (e) {
      print("Error loading users in UserController: $e");
    }
  }

  // Add user
  Future<void> addUser(UserModel user) async {
    await _userRepository.addUser(user);
    await loadUsers(); // Reload users after adding
  }

  Future<void> promoteUserToAdmin(String userId) async {
    try {
      await _userRepository.updateUserRole(userId, 'admin');
      final index = users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        users[index] = users[index].copyWith(role: Role.admin);
        users.refresh();
      }
      Get.snackbar('Success', 'User has been promoted to Admin');
    } catch (e) {
      Get.snackbar('Error', 'Failed to promote user: $e');
    }
  }

  // Update user
  Future<void> updateUser({
    required UserModel user,
    String? newPassword,
  }) async {
    try {
      // Update Firestore User Data
      await _userRepository.updateUserDetails(user);

      // Update Firebase Authentication Email (if changed)
      if (user.email != _authRepository.authUser!.email) {
        await _authRepository.updateEmail(user.email);
      }

      // Update Firebase Authentication Password (if provided)
      if (newPassword != null && newPassword.isNotEmpty) {
        await _authRepository.updatePassword(newPassword);
      }

      Get.snackbar('Success', 'User updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _userRepository.deleteUser(userId);
    await loadUsers(); // Reload users after deleting
  }

  // Save user records from any registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials?.user == null) return;

      // Get the current user from Firebase Auth
      final currentUser = userCredentials!.user!;

      // Get existing user data if any
      final existingUserDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      // If user already exists, just refresh the user data
      if (existingUserDoc.exists) {
        await initializeUser();
        return;
      }

      // For new users, create a new UserModel
      final nameparts = UserModel.nameParts(currentUser.displayName ?? '');
      final username =
          UserModel.generateUsername(currentUser.displayName ?? '');

      final user = UserModel(
        id: currentUser.uid,
        username: username,
        email: currentUser.email ?? '',
        firstName: nameparts[0],
        lastName: nameparts.length > 1 ? nameparts.sublist(1).join(' ') : '',
        phoneNumber: currentUser.phoneNumber ?? '',
        profilePicture: currentUser.photoURL ?? '',
        role: Role.user,
      );

      // Save user data to Firestore
      await _userRepository.saveUserRecords(user);

      // Initialize user data in the controller
      await initializeUser();
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Data Not Saved',
        message:
            'Something went wrong while saving your information. You can re-save your data in your profile',
      );
    }
  }

  // Delete account warning popup
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText:
          'Are you sure you want to delete your account? This action is not reversible and all of your data will be lost',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  // Delete user account
  void deleteUserAccount() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Processing...', TImages.docerAnimation);

      // First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider =
          auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
        // Re-verify auth email
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

  // Re-authenticate before deleting
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

      await _authRepository.reAuthenticateEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );

      await _authRepository.deleteAccount();

      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
