import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/models/category.dart';

class StoreController extends GetxController {
  final RxString selectedBrandId = ''.obs;
  final RxString selectedBrandName = ''.obs;

  // Fetch featured brands from Firestore
  Future<List<Map<String, dynamic>>> fetchFeaturedBrands() async {
    final brandsSnapshot =
        await FirebaseFirestore.instance.collection('brands').get();

    final featuredBrands = await Future.wait(
      brandsSnapshot.docs.map((doc) async {
        final brandId = doc.id;
        final productCount = await FirebaseFirestore.instance
            .collection('products')
            .where('brandId', isEqualTo: brandId)
            .get()
            .then((snapshot) => snapshot.docs.length);

        return {
          'id': brandId,
          'name': doc['name'],
          'logoUrl': doc['logoUrl'],
          'productCount': productCount,
        };
      }),
    );

    return featuredBrands;
  }

  // Fetch products for the selected brand
  Stream<QuerySnapshot> fetchProductsByBrand(String brandId) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .snapshots();
  }

  // Convert Firestore document to Product object
  Product productFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? 'Unnamed Product',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      category: Category(
        id: data['categoryId'] ?? '',
        name: data['categoryName'] ?? '',
        imagUrl: data['categoryImageUrl'] ?? '',
      ),
      brand: Brand(
        id: data['brandId'] ?? '',
        name: data['brandName'] ?? '',
        logoUrl: data['brandLogoUrl'] ?? '',
      ),
    );
  }

  // Select a brand
  void selectBrand(String brandId, String brandName) {
    if (selectedBrandId.value == brandId) {
      selectedBrandId.value = '';
      selectedBrandName.value = '';
    } else {
      selectedBrandId.value = brandId;
      selectedBrandName.value = brandName;
    }
  }
}
