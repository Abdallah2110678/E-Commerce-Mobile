import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';


const uuid= Uuid();
class Product {
  String id;
  String title;
  String description;
  String thumbnailUrl;
  List<String> imageUrls;
  double price;
  double discount;
  int stock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.imageUrls,
    required this.price,
    required this.discount,
    required this.stock,
  });

  // Calculate the discounted price
  double get discountedPrice {
    return price - (price * (discount / 100));
  }

  // Convert a Firestore document to a Product object
  // Factory constructor for creating a Product from Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id, // Use Firestore document ID as the product ID
      title: data['title'] ?? '', // Provide a default value in case the field is null
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []), // Ensure it's a List<String>
      price: (data['price'] as num).toDouble(), // Convert num to double
      discount: (data['discount'] as num).toDouble(),
      stock: (data['stock'] as num).toInt(),
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
    };
  }
}