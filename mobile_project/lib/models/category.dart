import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  // Factory constructor to create a Category from Firestore
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id, // Use Firestore document ID as the category ID
      name: data['name'] ?? '', // Default value if name is null
    );
  }

  // Convert a Category object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
  // Add copyWith method to create a new instance with optional modifications
  Category copyWith({String? id, String? name}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
