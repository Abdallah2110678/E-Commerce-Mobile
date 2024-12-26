import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/services/product_service.dart';
import 'package:uuid/uuid.dart';

class ProductController {
  final FirebaseService firebaseService = FirebaseService();


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
List<Product> products = [];
DocumentSnapshot? lastDocument;
bool hasMore = true;
final int pageSize = 5;

// Cache for brands to avoid repeated fetches
Map<String, Brand> brandsCache = {};

// Fetch and cache all brands first
Future<Map<String, Brand>> fetchAllBrands() async {
  if (brandsCache.isEmpty) {
    final QuerySnapshot brandSnapshot = await _firestore
        .collection('brands')
        .get();
        
    for (var doc in brandSnapshot.docs) {
      brandsCache[doc.id] = Brand.fromFirestore(doc);
    }
  }
  return brandsCache;
}

// Fetch products with pagination
Future<List<Product>> fetchProducts() async {
  if (!hasMore) return products;

  try {
    // Fetch all brands first
    await fetchAllBrands();

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

      // Fetch categories for these products
      Map<String, Category> categoriesCache = {};
      
      // Get unique category IDs from the products
      Set<String> categoryIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['categoryId'] as String)
          .toSet();

      // Fetch all needed categories at once
      for (String categoryId in categoryIds) {
        DocumentSnapshot categoryDoc = await _firestore
            .collection('categories')
            .doc(categoryId)
            .get();
            
        categoriesCache[categoryId] = Category.fromFirestore(categoryDoc);
      }

      // Create Product objects
      List<Product> newProducts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String categoryId = data['categoryId'];
        String brandId = data['brandId'];

        return Product.fromFirestore(
          doc,
          category: categoriesCache[categoryId]!,
          brand: brandsCache[brandId]!,
        );
      }).toList();

      products.addAll(newProducts);
    }
    
    return products;
  } catch (e) {
    print('Error fetching products: $e');
    return products;
  }
}

// Function to reset pagination
void resetPagination() {
  products.clear();
  lastDocument = null;
  hasMore = true;
  brandsCache.clear();
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
    required String thumbnailUrl,  // Changed from thumbnail File
    required List<String> imageUrls,  // Changed from List<File>
    required double price,
    required double discount,
    required int stock,
    required Category category,
    required Brand brand,
  }) async {
    try {
      // Create product object with URLs directly
      Product product = Product(
        id: const Uuid().v4(),
        title: title,
        description: description,
        thumbnailUrl: thumbnailUrl,
        imageUrls: imageUrls,
        price: price,
        discount: discount,
        stock: stock,
        category: category,
        brand: brand,
      );

      // Save product to Firestore
      await firebaseService.saveProduct(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }
}
