import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class BrandController extends GetxController {
  RxString selectedLogo = ''.obs;
  TextEditingController nameController = TextEditingController();

  // Firebase and Supabase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Loading state
  RxBool isLoading = false.obs;

  // Function to pick a logo from the gallery
  Future<void> pickLogo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedLogo.value = pickedFile.path;
    }
  }

  // Function to reset the logo
  void resetLogo() {
    selectedLogo.value = '';
  }

  // Function to clear all inputs
  void clearInputs() {
    nameController.clear();
    resetLogo();
  }

  Future<void> ensureBucketExists() async {
    try {
      // Try to get bucket info to check if it exists
      await _supabase.storage.getBucket('brands');
    } catch (e) {
      if (e is StorageException && e.statusCode == '404') {
        // Bucket doesn't exist, create it
        try {
          await _supabase.storage.createBucket(
            'brands',
            const BucketOptions(
              public: true, // Make bucket public
              // 2MB limit
            ),
          );

          // Add policy for public access
          await _supabase.rpc('create_storage_policy', params: {
            'bucket_name': 'brands',
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

  Future<void> saveBrand() async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        throw 'Brand name is required';
      }

      if (selectedLogo.value.isEmpty) {
        throw 'Please select a logo';
      }

      // Ensure bucket exists before upload
      await ensureBucketExists();

      // Generate unique filename
      final String fileExtension = path.extension(selectedLogo.value);
      final String uniqueFileName =
          'brand_logos/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Upload logo to Supabase
      final File logoFile = File(selectedLogo.value);

      // Check file size (2MB limit)
      final fileSize = await logoFile.length();
      if (fileSize > 2 * 1024 * 1024) {
        throw 'Image size must be less than 2MB';
      }

      // Check file type
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
      if (!validExtensions.contains(fileExtension.toLowerCase())) {
        throw 'Only JPG, PNG and GIF files are allowed';
      }

      try {
          await _supabase.storage.from('brands').upload(
              uniqueFileName,
              logoFile,
              fileOptions: FileOptions(
                contentType: 'image/${fileExtension.substring(1)}',
                upsert: true,
              ),
            );

        // Get public URL
        final String logoUrl =
            _supabase.storage.from('brands').getPublicUrl(uniqueFileName);

        // Save to Firebase
        final brandData = {
          'name': nameController.text.trim(),
          'logoUrl': logoUrl,
        };

        await _firestore.collection('brands').add(brandData);

        clearInputs();
        fetchFeaturedBrands();
        Get.snackbar(
          'Success',
          'Brand created successfully',
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

//////////////////////////////////////////////
// Observable list for brands
  final brands = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedBrands(); // Fetch brands when the controller is initialized
  }

  // Method to fetch featured brands
  Future<void> fetchFeaturedBrands() async {
    try {
      final brandsSnapshot =
          await FirebaseFirestore.instance.collection('brands').get();

      // Retrieve brands with product counts
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

      brands.assignAll(featuredBrands); // Update the observable list
    } catch (e) {
      Get.snackbar('Error', 'Failed to load brands: $e');
    }
  }

  Future<void> deleteBrandIfNotUsed(String brandId, String logoUrl) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('brandId', isEqualTo: brandId)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        Get.snackbar(
          'Cannot Delete Brand',
          'This brand is associated with ${productSnapshot.docs.length} products.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Temporarily remove the brand from the state
      final removedBrand = brands.firstWhere(
        (brand) => brand['id'] == brandId,
        orElse: () => {},
      );
      brands.removeWhere((brand) => brand['id'] == brandId);

      // Variable to track if deletion should proceed
      bool shouldDelete = true;

      // Create a timer for countdown
      const int totalSeconds = 7;
      RxInt remainingSeconds = totalSeconds.obs;

      Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          timer.cancel();
        }
      });

      // Show snackbar with Undo option and countdown
      Get.snackbar(
        'Brand Deleted',
        'Brand deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: totalSeconds),
        messageText: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Brand deleted successfully.',
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
            // Re-add the brand to the state
            if (removedBrand.isNotEmpty) {
              brands.add(removedBrand);
            }
            // Dismiss the snackbar
            if (Get.isSnackbarOpen) {
              Get.back();
            }
            // Cancel the timer
            remainingSeconds.value = 0;
          },
          child: const Text(
            'UNDO',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      // Wait for snackbar duration
      await Future.delayed(const Duration(seconds: totalSeconds));

      try {
        // Extract the file path from the logo URL
        final String filePath =
            Uri.parse(logoUrl).pathSegments.skip(1).join('/');

        // Delete the file from Supabase
        await _supabase.storage.from('brand').remove([filePath]);
      } catch (storageError) {
        print('Error deleting image from Supabase: $storageError');
      }

      // Only proceed with deletion if shouldDelete is still true
      if (shouldDelete && !brands.any((brand) => brand['id'] == brandId)) {
        await FirebaseFirestore.instance
            .collection('brands')
            .doc(brandId)
            .delete();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete brand: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  RxString edit_selectedLogo = ''.obs;
  TextEditingController edit_nameController = TextEditingController();
// Function to pick a logo for editing from the gallery
  Future<void> pickEditLogo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      edit_selectedLogo.value = pickedFile.path;
    }
  }

  Future<void> editBrand({
    required String brandId,
    required String newName,
    required String newLogoPath,
    required String currentLogoUrl,
  }) async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (newName.trim().isEmpty) {
        throw 'Brand name is required';
      }

      // Variable to hold the updated logo URL
      String updatedLogoUrl = currentLogoUrl;

      // Check if a new logo is provided
      if (newLogoPath.isNotEmpty && newLogoPath != currentLogoUrl) {
        await ensureBucketExists();

        try {
          if (currentLogoUrl.isNotEmpty) {
            // Extract the file path from the logo URL
            final String filePath =
                Uri.parse(currentLogoUrl).pathSegments.skip(1).join('/');
            print('Deleting file from path: $filePath');

            // Delete the file from Supabase
            await _supabase.storage.from('brands').remove([filePath]);
            print('File deleted successfully from Supabase: $currentLogoUrl');
          } else {
            print('No logo URL provided to delete.');
          }
        } catch (e) {
          print('Error deleting old logo from Supabase: $e');
          throw 'Failed to delete the old logo.';
        }

        final String fileExtension = path.extension(newLogoPath);
        final String uniqueFileName =
            'brand_logos/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

        final File logoFile = File(newLogoPath);

        // Check file size and type
        if (await logoFile.length() > 2 * 1024 * 1024) {
          throw 'Image size must be less than 2MB';
        }
        if (!['.jpg', '.jpeg', '.png', '.gif']
            .contains(fileExtension.toLowerCase())) {
          throw 'Only JPG, PNG, and GIF files are allowed';
        }

        try {
          // Upload new logo
          await _supabase.storage.from('brands').upload(
                uniqueFileName,
                logoFile,
                fileOptions: FileOptions(
                  contentType: 'image/${fileExtension.substring(1)}',
                  upsert: true,
                ),
              );

          // Get public URL
          updatedLogoUrl =
              _supabase.storage.from('brands').getPublicUrl(uniqueFileName);

          // Delete the old logo
          if (currentLogoUrl.isNotEmpty) {
            final String filePath =
                Uri.parse(currentLogoUrl).pathSegments.skip(1).join('/');
            await _supabase.storage.from('brands').remove([filePath]);
            print(currentLogoUrl);
          }
        } catch (e) {
          print('Error uploading logo: $e');
          throw 'Failed to upload the new logo.';
        }
      }

      // Update Firebase
      await _firestore.collection('brands').doc(brandId).update({
        'name': newName.trim(),
        'logoUrl': updatedLogoUrl,
      });

      fetchFeaturedBrands();
      Get.snackbar(
        'Success',
        'Brand updated successfully',
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
