// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:path/path.dart' as path;

class CategoryController extends GetxController {
  RxString selectedImage = ''.obs;
  TextEditingController nameController = TextEditingController();

  // Firebase and Supabase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Loading state
  RxBool isLoading = false.obs;

  // Observable list for categories
  final categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage.value = pickedFile.path;
    }
  }

  // Function to clear all inputs
  void clearInputs() {
    nameController.clear();
    selectedImage.value = '';
  }

  Future<void> ensureBucketExists() async {
    try {
      await _supabase.storage.getBucket('categories');
    } catch (e) {
      if (e is StorageException && e.statusCode == '404') {
        try {
          await _supabase.storage.createBucket(
            'categories',
            const BucketOptions(
              public: true,
            ),
          );

          await _supabase.rpc('create_storage_policy', params: {
            'bucket_name': 'categories',
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

  Future<void> saveCategory() async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        throw 'Category name is required';
      }

      if (selectedImage.value.isEmpty) {
        throw 'Please select an image';
      }

      await ensureBucketExists();

      final String fileExtension = path.extension(selectedImage.value);
      final String uniqueFileName = 'category_images/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      final File imageFile = File(selectedImage.value);

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

      try {
        await _supabase.storage.from('categories').upload(
          uniqueFileName,
          imageFile,
          fileOptions: FileOptions(
            contentType: 'image/${fileExtension.substring(1)}',
            upsert: true,
          ),
        );

        final String imagUrl = _supabase.storage.from('categories').getPublicUrl(uniqueFileName);

        final categoryData = {
          'name': nameController.text.trim(),
          'imagUrl': imagUrl,
        };

        await _firestore.collection('categories').add(categoryData);

        clearInputs();
        fetchCategories();
        Get.snackbar(
          'Success',
          'Category created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (uploadError) {
        print('Upload error: $uploadError');
        throw 'Failed to upload image. Please try again.';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();

      final fetchedCategories = await Future.wait(
        categoriesSnapshot.docs.map((doc) async {
          final categoryId = doc.id;
          final productCount = await FirebaseFirestore.instance
              .collection('products')
              .where('categoryId', isEqualTo: categoryId)
              .get()
              .then((snapshot) => snapshot.docs.length);

          return {
            'id': categoryId,
            'name': doc['name'],
            'imagUrl': doc['imagUrl'],
            'productCount': productCount,
          };
        }),
      );

      categories.assignAll(fetchedCategories);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    }
  }

  Future<void> deleteCategoryIfNotUsed(String categoryId, String imagUrl) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        Get.snackbar(
          'Cannot Delete Category',
          'This category is associated with ${productSnapshot.docs.length} products.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final removedCategory = categories.firstWhere(
        (category) => category['id'] == categoryId,
        orElse: () => {},
      );
      categories.removeWhere((category) => category['id'] == categoryId);

      bool shouldDelete = true;
      const int totalSeconds = 7;
      RxInt remainingSeconds = totalSeconds.obs;

      Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          timer.cancel();
        }
      });

      Get.snackbar(
        'Category Deleted',
        'Category deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: totalSeconds),
        messageText: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category deleted successfully.',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Undo (${remainingSeconds.value}s)',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        )),
        mainButton: TextButton(
          onPressed: () {
            shouldDelete = false;
            if (removedCategory.isNotEmpty) {
              categories.add(removedCategory);
            }
            if (Get.isSnackbarOpen) {
              Get.back();
            }
            remainingSeconds.value = 0;
          },
          child: const Text(
            'UNDO',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: totalSeconds));

      try {
        final String filePath = Uri.parse(imagUrl).pathSegments.skip(1).join('/');
        await _supabase.storage.from('categories').remove([filePath]);
      } catch (storageError) {
        print('Error deleting image from Supabase: $storageError');
      }

      if (shouldDelete && !categories.any((category) => category['id'] == categoryId)) {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .delete();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Edit functionality
  RxString edit_selectedImage = ''.obs;
  TextEditingController edit_nameController = TextEditingController();

  Future<void> pickEditImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      edit_selectedImage.value = pickedFile.path;
    }
  }

  Future<void> editCategory({
    required String categoryId,
    required String newName,
    required String newImagePath,
    required String currentimagUrl,
  }) async {
    try {
      isLoading.value = true;

      if (newName.trim().isEmpty) {
        throw 'Category name is required';
      }

      String updatedimagUrl = currentimagUrl;

      if (newImagePath.isNotEmpty && newImagePath != currentimagUrl) {
        await ensureBucketExists();

        final String fileExtension = path.extension(newImagePath);
        final String uniqueFileName = 'category_images/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

        final File imageFile = File(newImagePath);

        if (await imageFile.length() > 2 * 1024 * 1024) {
          throw 'Image size must be less than 2MB';
        }
        if (!['.jpg', '.jpeg', '.png', '.gif'].contains(fileExtension.toLowerCase())) {
          throw 'Only JPG, PNG, and GIF files are allowed';
        }

        try {
          await _supabase.storage.from('categories').upload(
            uniqueFileName,
            imageFile,
            fileOptions: FileOptions(
              contentType: 'image/${fileExtension.substring(1)}',
              upsert: true,
            ),
          );

          updatedimagUrl = _supabase.storage.from('categories').getPublicUrl(uniqueFileName);

          if (currentimagUrl.isNotEmpty) {
            final String filePath = Uri.parse(currentimagUrl).pathSegments.skip(1).join('/');
            await _supabase.storage.from('categories').remove([filePath]);
          }
        } catch (e) {
          print('Error uploading image: $e');
          throw 'Failed to upload the new image.';
        }
      }

      await _firestore.collection('categories').doc(categoryId).update({
        'name': newName.trim(),
        'imagUrl': updatedimagUrl,
      });

      fetchCategories();
      Get.snackbar(
        'Success',
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}