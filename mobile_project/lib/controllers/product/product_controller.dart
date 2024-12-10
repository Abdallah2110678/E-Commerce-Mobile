import 'dart:io';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/service/product_service.dart';

class ProductController {
  final FirebaseService firebaseService = FirebaseService();

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
        
        title: title,
        description: description,
        thumbnailUrl: "thumbnailUrl",
        imageUrls: [],
        price: price,
        discount: discount,
        stock: stock,
      );

      // Save product to Firestore
      await firebaseService.saveProduct(product.toJson());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }
}
