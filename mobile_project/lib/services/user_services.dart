import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:flutter/material.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/utils/exceptions/firebase_exceptions.dart';
import 'package:mobile_project/utils/exceptions/format_exceptions.dart';
import 'package:mobile_project/utils/exceptions/platform_exceptions.dart';
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //function to save data t firestore
  Future<void> saveUserRecords(UserModel user) async {
    try {
      return await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _db.collection("users").get();
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }
  // Add a user to Firestore
  Future<void> addUser(UserModel user) async {
    try {
      await _db.collection("users").add(user.toMap());
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  // Update user in Firestore
  Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection("user").doc(user.id).update(user.toMap());
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Delete user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection("user").doc(userId).delete();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
