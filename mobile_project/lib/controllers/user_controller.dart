import 'package:flutter/material.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/services/user_services.dart';

class UserController extends ChangeNotifier {
  List<UserModel> users = [];

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
}
