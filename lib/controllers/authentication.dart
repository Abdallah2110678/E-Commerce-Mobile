import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/screens/login/login.dart';
import 'package:mobile_project/services/user_services.dart';
import 'package:mobile_project/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:mobile_project/utils/exceptions/firebase_exceptions.dart';
import 'package:mobile_project/utils/exceptions/format_exceptions.dart';
import 'package:mobile_project/utils/exceptions/platform_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  ///variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  //get authentication user data
  User? get authUser => _auth.currentUser;

  ///called from main
  @override
  void onReady() {
    FlutterNativeSplash.remove();
  }

  /*-----------------------------email & password sign_in-----------------------*/
  //login
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        // Initialize and refresh UserController after successful login
        await Get.find<UserController>().initializeUser();
        return userCredential;
      } else {
        throw 'Authentication failed';
      }
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

  //signin
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

//verifyBeforeUpdateEmail
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
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

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
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

  //Google signin
  Future<UserCredential> signInWithGoogle() async {
    try {
      //trigger auth flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      //obtain auth details
      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;
      //create a new credential
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      //sign in to firebase
      return await _auth.signInWithCredential(credentials);
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

  Future<void> reAuthenticateEmailAndPassword(
      String email, String password) async {
    try {
      //create a credential
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);

      //ReAuthentication
      await _auth.currentUser!.reauthenticateWithCredential(credential);
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

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      final userController = Get.find<UserController>();
      userController.clearUser();
      Get.offAll(() => const LoginScreen());

      // Optional: Show a success message
      Get.snackbar('Logged Out', 'You have been successfully logged out.');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      Get.snackbar('Logout Error', TFirebaseAuthException(e.code).message);
    } on FirebaseException catch (e) {
      // Handle general Firebase errors
      Get.snackbar('Logout Error', TFirebaseException(e.code).message);
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      Get.snackbar('Logout Error', TPlatformException(e.code).message);
    } catch (e) {
      // Handle any other errors
      Get.snackbar('Logout Error', 'Something went wrong: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
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
