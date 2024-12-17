import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/category.dart';

class Product {
  String id;
  String title;
  String description;
  String thumbnailUrl;
  List<String> imageUrls;
  double price;
  double discount;
  int stock;
  Category category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.imageUrls,
    required this.price,
    required this.discount,
    required this.stock,
    required this.category,
  });

  // Calculate the discounted price
  double get discountedPrice {
    return price - (price * (discount / 100));
  }

  // Convert a Firestore document to a Product object
  // Factory constructor for creating a Product from Firestore
  factory Product.fromFirestore(DocumentSnapshot doc, Category category) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  return Product(
    id: doc.id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    thumbnailUrl: data['thumbnailUrl'] ?? '',
    imageUrls: List<String>.from(data['imageUrls'] ?? []),
    price: (data['price'] as num).toDouble(),
    discount: (data['discount'] as num).toDouble(),
    stock: (data['stock'] as num).toInt(),
    category: category,
  );
}

  // Convert a Product object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'imageUrls': imageUrls,
      'price': price,
      'discount': discount,
      'stock': stock,
      'categoryId': category.id,
    };
  }
}