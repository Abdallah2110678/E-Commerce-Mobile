import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageService {
  // Save image to assets folder
  Future<String> saveImageToAssets(File imageFile) async {
    try {
      // Create a directory for product images in the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory('${appDir.path}/assets/images/products');
      
      // Create the directory if it doesn't exist
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      // Generate a unique filename
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      
      // Full path for the new image
      String newPath = '${assetsDir.path}/$uniqueFileName';
      
      // Copy the file to the new location
      File newImage = await imageFile.copy(newPath);
      
      // Return the relative path
      return 'assets/images/products/$uniqueFileName';
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  // Delete an image
  Future<void> deleteImage(String imagePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$imagePath';
      
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}