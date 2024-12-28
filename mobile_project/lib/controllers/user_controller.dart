import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/utils/popups/loaders.dart';

class UserController extends ChangeNotifier {
  List<UserModel> users = [];

  final userRepository = Get.put(UserRepository());

  // Initialize and load users
  Future<void> loadUsers() async {
    try {
      users = await UserRepository().getUsers();
      notifyListeners(); // Notify UI to rebuild
    } catch (e) {
      print("Error loading users in UserController: $e");
    }
  }

  // Add user
  Future<void> addUser(UserModel user) async {
    await UserRepository().addUser(user);
    await loadUsers(); // Reload users after adding
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    await UserRepository().updateUser(user);
    await loadUsers(); // Reload users after updating
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await UserRepository().deleteUser(userId);
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
}
