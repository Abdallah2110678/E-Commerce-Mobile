import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/service/product_service.dart';
import 'package:uuid/uuid.dart';

class ProductController {
  final FirebaseService firebaseService = FirebaseService();


 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> products = [];
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  final int pageSize = 5;

  // Fetch products with pagination
  Future<List<Product>> fetchProducts() async {
    if (!hasMore) return [];

    Query query = _firestore
        .collection('products')
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      if (snapshot.docs.length < pageSize) hasMore = false;
      products.addAll(snapshot.docs.map((doc) => Product.fromFirestore(doc)));
    }
    return products;
  }

  // Delete a product
  Future<void> deleteProduct(Product product) async {
    try {
      // Delete the document
      await _firestore.collection('products').doc(product.id).delete();

      // Optionally delete the image from Firebase Storage
      // await FirebaseStorage.instance.ref(product.imagePath).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }








  Future<void> createProduct({
    required String title,
    required String description,
    required File thumbnail,
    required List<File> images,
    required double price,
    required double discount,
    required int stock,
  }) async {
    try {
      // // Upload thumbnail
      // String thumbnailUrl = await firebaseService.uploadImage(
      //   thumbnail,
      //   'products/thumbnails/${DateTime.now().toIso8601String().replaceAll(":", "-")}'

      // );

      // Upload gallery images
      // List<String> imageUrls = [];
      // for (var image in images) {
      //   String imageUrl = await firebaseService.uploadImage(
      //     image,
      //     'products/images/${DateTime.now().toIso8601String()}_${image.hashCode}',
      //   );
      //   imageUrls.add(imageUrl);
      // }

      // Create product object
      Product product = Product(
        id: const Uuid().v4(),
        title: title,
        description: description,
        thumbnailUrl: "thumbnailUrl",
        imageUrls: [],
        price: price,
        discount: discount,
        stock: stock,
      );

      // Save product to Firestore
      await firebaseService.saveProduct(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }
}
