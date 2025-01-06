import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch categories from Firestore
  Future<List<Category>> fetchCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  // Add a new category to Firestore
  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toFirestore());
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).update({
      'name': category.name,
    });
  }

  // Check if category is used in products
  Future<bool> isCategoryUsedInProducts(String categoryId) async {
    QuerySnapshot productSnapshot = await _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    
    return productSnapshot.docs.isNotEmpty;
  }

  // Delete a category from Firestore
  Future<bool> deleteCategory(String id) async {
    // First, check if the category is used in any products
    bool isUsed = await isCategoryUsedInProducts(id);
    
    if (isUsed) {
      return false; // Indicate that deletion was not possible
    }
    
    await _firestore.collection('categories').doc(id).delete();
    return true; // Indicate successful deletion
  }
}