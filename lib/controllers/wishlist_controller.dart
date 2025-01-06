// lib/controllers/wishlist_controller.dart
import 'package:get/get.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/database/DBHelper.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/brand.dart';

class WishlistController extends GetxController {
  final RxList<Product> wishlistItems = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final List<Category> categories = [];  // Assume this is preloaded with categories
  final List<Brand> brands = [];        // Assume this is preloaded with brands

  @override
  void onInit() {
    super.onInit();
    loadWishlistItems();
  }

  Future<void> loadWishlistItems() async {
    try {
      isLoading.value = true;
      List<Product> items = await DBHelper.getWishlistItems(categories, brands);
      wishlistItems.assignAll(items);
      isLoading.value = false;
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> toggleWishlist(Product product) async {
    try {
      final isAlreadyInWishlist = wishlistItems.any((item) => item.id == product.id);

      if (isAlreadyInWishlist) {
        // Remove from wishlist
        await DBHelper.removeProduct(product.id);
        wishlistItems.removeWhere((item) => item.id == product.id);
        Get.snackbar('Success', 'Removed from wishlist');
      } else {
        // Add to wishlist
        await DBHelper.insertProduct(product);
        wishlistItems.add(product);
        Get.snackbar('Success', 'Added to wishlist');
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }

  bool isInWishlist(Product product) {
    return wishlistItems.any((item) => item.id == product.id);
  }
}
