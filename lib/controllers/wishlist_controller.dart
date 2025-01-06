// lib/controllers/wishlist_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final RxList<Product> wishlistItems = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlistItems();
  }

  Future<void> loadWishlistItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Listen to wishlist changes in real-time
        _firestore
            .collection('wishlist')
            .doc(userId)
            .collection('items')
            .snapshots()
            .listen((snapshot) async {
          List<Product> items = [];
          for (var doc in snapshot.docs) {
            final productId = doc.data()['productId'];
            final productDoc =
                await _firestore.collection('products').doc(productId).get();
            final categoryDoc = await _firestore
                .collection('categories')
                .doc(productDoc['categoryId'])
                .get();
            final brandDoc = await _firestore
                .collection('brands')
                .doc(productDoc['brandId'])
                .get();

            if (productDoc.exists) {
              items.add(Product.fromFirestore(
                productDoc,
                category: Category.fromFirestore(categoryDoc),
                brand: Brand.fromFirestore(brandDoc),
              ));
            }
          }
          wishlistItems.assignAll(items);
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> toggleWishlist(Product product) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Please login to add items to wishlist');
        return;
      }

      final docRef = _firestore
          .collection('wishlist')
          .doc(userId)
          .collection('items')
          .doc(product.id);

      final doc = await docRef.get();
      if (doc.exists) {
        // Remove from wishlist
        await docRef.delete();
        Get.snackbar('Success', 'Removed from wishlist');
      } else {
        // Add to wishlist
        await docRef.set({
          'productId': product.id,
          'addedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Added to wishlist');
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }

  bool isInWishlist(Product product) {
    return wishlistItems.any((item) => item.id == product.id);
  }
}
