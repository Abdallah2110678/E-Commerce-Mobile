import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Upload image file to Firebase Storage
// Future<String> uploadImage(File file, String path) async {
//   try {
//     final Reference ref = storage.ref().child(path);
//     final UploadTask uploadTask = ref.putFile(file);
//     final TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   } catch (e) {
//     print('Upload failed: $e');
//     throw Exception('Failed to upload image: $e');
//   }
// }

  // Save product to Firestore
  Future<void> saveProduct(Map<String, dynamic> productData) async {
    try {
      await firestore.collection('products').add(productData);
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }
}
