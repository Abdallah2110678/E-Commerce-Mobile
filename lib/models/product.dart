import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/brand.dart';
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
  Brand brand;

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
    required this.brand,
  });

  // Calculate the discounted price
  double get discountedPrice {
    return price - (price * (discount / 100));
  }

  
  factory Product.fromFirestore(
    DocumentSnapshot doc, {
    required Category category,
    required Brand brand,
  }) {
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
    brand: brand,
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
      'brandId': brand.id,
    };
  }
}