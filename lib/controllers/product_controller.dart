import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/utils/popups/loaders.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/services/product_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Text Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final stockController = TextEditingController();

  // Observable values
  final selectedThumbnail = ''.obs;
  final isLoading = false.obs;

  RxList<Category> categories =
      <Category>[].obs; // Observable list of categories
  Rxn<Category> selectedCategory =
      Rxn<Category>(); // Observable for selected category
  RxList<Brand> brands = <Brand>[].obs; // Observable list of brands
  Rxn<Brand> selectedBrand = Rxn<Brand>(); // Observable for selected brand

  final editTitleController = TextEditingController();
  final editDescriptionController = TextEditingController();
  final editPriceController = TextEditingController();
  final editDiscountController = TextEditingController();
  final editStockController = TextEditingController();

  // Observable values
  final editSelectedThumbnail = ''.obs;
  Rxn<Category> editSelectedCategory = Rxn<Category>(); // reactive nullable
  Rxn<Brand> editSelectedBrand = Rxn<Brand>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBrands();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountController.dispose();
    stockController.dispose();
    super.onClose();
  }

  Future<void> ensureBucketExists() async {
    try {
      await _supabase.storage.getBucket('products');
    } catch (e) {
      if (e is StorageException && e.statusCode == '404') {
        try {
          await _supabase.storage.createBucket(
            'products',
            const BucketOptions(
              public: true,
            ),
          );

          await _supabase.rpc('create_storage_policy', params: {
            'bucket_name': 'products',
            'policy_name': 'Public Access',
          });
        } catch (createError) {
          print('Error creating bucket: $createError');
          throw 'Failed to create storage bucket';
        }
      } else {
        print('Error checking bucket: $e');
        throw 'Failed to check storage bucket';
      }
    }
  }

  Future<void> fetchBrands() async {
    try {
      // Fetching brands from Firestore
      final brandsSnapshot =
          await FirebaseFirestore.instance.collection('brands').get();
      final List<Brand> fetchedBrands = brandsSnapshot.docs.map((doc) {
        return Brand(
          id: doc.id,
          name: doc.data()['name'] ?? '', // Default if 'name' is missing
          logoUrl:
              doc.data()['logoUrl'] ?? '', // Default if 'logoUrl' is missing
        );
      }).toList();
      brands.assignAll(fetchedBrands);
      print('Brands fetched successfully: ${brands.length}');
    } catch (e) {
      // Error handling
      Get.snackbar('Error', 'Failed to load brands: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final categoriesSnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final List<Category> fetchedCategories = categoriesSnapshot.docs
          .map((doc) => Category(
                id: doc.id,
                name: doc['name'],
                imagUrl: doc['imagUrl'],
              ))
          .toList();

      categories.assignAll(fetchedCategories);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      isLoading.value = true;

    if (!formKey.currentState!.validate()) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Please fill in all required fields');
    }
    
      if (editSelectedThumbnail.value.isEmpty) {
        throw 'Please select a thumbnail image';
      }


      String updatedThumbnailUrl = product.thumbnailUrl;

      // Handle new thumbnail upload if it's different from the current one
      if (editSelectedThumbnail.value.isNotEmpty &&
          editSelectedThumbnail.value != product.thumbnailUrl) {
        await ensureBucketExists();

        final String fileExtension =
            path.extension(editSelectedThumbnail.value);
        final String uniqueFileName =
            'product_images/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

        final File imageFile = File(editSelectedThumbnail.value);

        // Validate image size and type
        if (await imageFile.length() > 2 * 1024 * 1024) {
          throw 'Image size must be less than 2MB';
        }
        if (!['.jpg', '.jpeg', '.png', '.gif']
            .contains(fileExtension.toLowerCase())) {
          throw 'Only JPG, PNG, and GIF files are allowed';
        }

        try {
          // Upload the new thumbnail to Supabase
          await _supabase.storage.from('products').upload(
                uniqueFileName,
                imageFile,
                fileOptions: FileOptions(
                  contentType: 'image/${fileExtension.substring(1)}',
                  upsert: true,
                ),
              );

          // Get the public URL of the uploaded image
          updatedThumbnailUrl =
              _supabase.storage.from('products').getPublicUrl(uniqueFileName);

          // Delete the old thumbnail from Supabase if it exists
          if (product.thumbnailUrl.isNotEmpty) {
            final String filePath =
                Uri.parse(product.thumbnailUrl).pathSegments.skip(1).join('/');
            await _supabase.storage.from('products').remove([filePath]);
            
          }
        } catch (e) {
          print('Error uploading image: $e');
          throw 'Failed to upload the new thumbnail.';
        }
      }

      // Update product in Firestore
      final updatedProduct = Product(
        id: product.id,
        title: editTitleController.text.trim(),
        description: editDescriptionController.text.trim(),
        thumbnailUrl: updatedThumbnailUrl,
        price: double.parse(editPriceController.text),
        discount: double.parse(editDiscountController.text),
        stock: int.parse(editStockController.text),
        category: editSelectedCategory.value!,
        brand: editSelectedBrand.value!,
        imageUrls: product.imageUrls, // Keep existing images
      );

      await _firestore
          .collection('products')
          .doc(product.id)
          .update(updatedProduct.toFirestore());

      TLoaders.successSnackBar(
          title: 'Success', message: 'Product updated successfully');

      fetchProducts();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editPickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      editSelectedThumbnail.value = pickedFile.path;
    }
  }

  Future<void> pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedThumbnail.value = pickedFile.path;
    }
  }

  Future<void> submitProduct() async {
    if (!formKey.currentState!.validate()) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Please fill in all required fields');
    }

    await ensureBucketExists();
    final String fileExtension = path.extension(selectedThumbnail.value);
    final String uniqueFileName =
        'product_images/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

    final File imageFile = File(selectedThumbnail.value);

    // Check file size (2MB limit)
    final fileSize = await imageFile.length();
    if (fileSize > 2 * 1024 * 1024) {
      throw 'Image size must be less than 2MB';
    }

    // Check file type
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    if (!validExtensions.contains(fileExtension.toLowerCase())) {
      throw 'Only JPG, PNG and GIF files are allowed';
    }

    await _supabase.storage.from('products').upload(
          uniqueFileName,
          imageFile,
          fileOptions: FileOptions(
            contentType: 'image/${fileExtension.substring(1)}',
            upsert: true,
          ),
        );
    final String imagUrl =
        _supabase.storage.from('products').getPublicUrl(uniqueFileName);

    if (selectedThumbnail.value.isEmpty) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Please select a thumbnail image');
      return;
    }

    try {
      isLoading.value = true;

      await createProduct(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        thumbnailUrl: imagUrl,
        price: double.parse(priceController.text),
        discount: double.parse(discountController.text),
        stock: int.parse(stockController.text),
        category: selectedCategory.value!,
        brand: selectedBrand.value!,
        imageUrls: [],
      );
      TLoaders.successSnackBar(
          title: 'Success', message: 'Product created successfully');
      resetForm();

    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to create product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    discountController.clear();
    stockController.clear();
    selectedThumbnail.value = '';
    selectedCategory.value = null;
  }

  final FirebaseService firebaseService = FirebaseService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> products = [];

// Cache for brands to avoid repeated fetches
  Map<String, Brand> brandsCache = {};

// Fetch and cache all brands first
  Future<Map<String, Brand>> fetchAllBrands() async {
    if (brandsCache.isEmpty) {
      final QuerySnapshot brandSnapshot =
          await _firestore.collection('brands').get();

      for (var doc in brandSnapshot.docs) {
        brandsCache[doc.id] = Brand.fromFirestore(doc);
      }
    }
    return brandsCache;
  }

// Fetch products with pagination
  Future<List<Product>> fetchProducts() async {
    try {
      // Fetch all brands first
      await fetchAllBrands();

      Query query = _firestore.collection('products');
      final QuerySnapshot snapshot = await query.get();
      // Fetch categories for these products
      Map<String, Category> categoriesCache = {};

      // Get unique category IDs from the products
      Set<String> categoryIds = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['categoryId'] as String)
          .toSet();

      // Fetch all needed categories at once
      for (String categoryId in categoryIds) {
        DocumentSnapshot categoryDoc =
            await _firestore.collection('categories').doc(categoryId).get();

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

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products');
    }
  }

  // Delete a product
  Future<void> deleteProduct(Product product) async {
    try {
      // Delete the document
      await _firestore.collection('products').doc(product.id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> createProduct({
    required String title,
    required String description,
    required String thumbnailUrl, // Changed from thumbnail File
    required List<String> imageUrls, // Changed from List<File>
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
