import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/models/ratingComment.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();
  final carousalCurrentIndex = 0.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> featuredProducts = <Product>[].obs;
  final RxString selectedCategoryId = ''.obs;
  final RxBool isLoading = false.obs;

  // Reference to Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  // Set selected category
  void setSelectedCategory(String? categoryId) {
    selectedCategoryId.value = categoryId ?? '';
    if (categoryId == null) {
      fetchAllProducts();
    } else {
      fetchProductsByCategory(categoryId);
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;

      // Get products filtered by category
      final QuerySnapshot productSnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // Temporary list to hold products
      List<Product> loadedProducts = [];

      // Process each document
      for (var doc in productSnapshot.docs) {
        // Fetch the category
        final categoryDoc = await _firestore
            .collection('categories')
            .doc(doc.get('categoryId'))
            .get();
        final category = Category.fromFirestore(categoryDoc);

        // Fetch the brand
        final brandDoc =
            await _firestore.collection('brands').doc(doc.get('brandId')).get();
        final brand = Brand.fromFirestore(brandDoc);

        // Create the product
        final product = Product.fromFirestore(
          doc,
          category: category,
          brand: brand,
        );

        loadedProducts.add(product);
      }

      // Update the observable list
      products.assignAll(loadedProducts);
    } catch (e) {
      print('Error fetching products by category: $e');
      Get.snackbar('Error', 'Failed to load category products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all products
  Future<void> fetchAllProducts() async {
    try {
      // Get the products collection
      final QuerySnapshot productSnapshot =
          await _firestore.collection('products').get();

      // Temporary list to hold products
      List<Product> loadedProducts = [];

      // Process each document
      for (var doc in productSnapshot.docs) {
        // Fetch the category
        final categoryDoc = await _firestore
            .collection('categories')
            .doc(doc.get('categoryId'))
            .get();
        final category = Category.fromFirestore(categoryDoc);

        // Fetch the brand
        final brandDoc =
            await _firestore.collection('brands').doc(doc.get('brandId')).get();
        final brand = Brand.fromFirestore(brandDoc);

        // Create the product
        final product = Product.fromFirestore(
          doc,
          category: category,
          brand: brand,
        );

        loadedProducts.add(product);
      }

      // Update the observable list
      products.assignAll(loadedProducts);
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  // Fetch featured products (limited to 6)
  Future<void> fetchFeaturedProducts() async {
    try {
      final QuerySnapshot productSnapshot =
          await _firestore.collection('products').limit(6).get();

      // Temporary list to hold products
      List<Product> loadedProducts = [];

      // Process each document
      for (var doc in productSnapshot.docs) {
        // Fetch the category
        final categoryDoc = await _firestore
            .collection('categories')
            .doc(doc.get('categoryId'))
            .get();
        final category = Category.fromFirestore(categoryDoc);

        // Fetch the brand
        final brandDoc =
            await _firestore.collection('brands').doc(doc.get('brandId')).get();
        final brand = Brand.fromFirestore(brandDoc);

        // Create the product
        final product = Product.fromFirestore(
          doc,
          category: category,
          brand: brand,
        );

        loadedProducts.add(product);
      }

      // Update the observable list
      featuredProducts.assignAll(loadedProducts);
    } catch (e) {
      print('Error fetching featured products: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Fetch products when controller is initialized
    fetchAllProducts();
    fetchFeaturedProducts();
  }

  // Method to check if the user has already rated the product
  Future<bool> hasUserRated({
    required String productId,
    required String userId,
  }) async {
    try {
      DocumentSnapshot productDoc =
          await _firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        List<dynamic> ratingComments = productDoc['ratingComments'] ?? [];
        return ratingComments.any((rc) => rc['userId'] == userId);
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check rating: $e');
      return false;
    }
  }

  // Method to add a rating and comment to a product
  Future<void> addRatingComment({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    try {
      // Create a new RatingComment object
      RatingComment newRatingComment = RatingComment(
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
      );

      // Get the product document reference
      DocumentReference productRef =
          _firestore.collection('products').doc(productId);

      // Update the product document with the new rating and comment
      await productRef.update({
        'ratingComments': FieldValue.arrayUnion([newRatingComment.toMap()]),
      });

      Get.snackbar('Success', 'Rating and comment added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add rating and comment: $e');
    }
  }
}
