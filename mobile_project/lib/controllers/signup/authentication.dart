import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_project/main.dart';
import 'package:mobile_project/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:mobile_project/utils/exceptions/firebase_exceptions.dart';
import 'package:mobile_project/utils/exceptions/format_exceptions.dart';
import 'package:mobile_project/utils/exceptions/platform_exceptions.dart';
import 'package:mobile_project/views/login/login.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  ///variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  ///called from main
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  screenRedirect() async {
    //local storage
    deviceStorage.writeIfNull('IsFristTime', true);
    //check if it's first time
    // deviceStorage.read('IsFristTime') != true ? Get.offAll(()=> const LoginScreen()): Get.offAll(const onboardingscreen());
  }

  /*-----------------------------email & password sign_in-----------------------*/

  //signin
  //Register
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
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
}
