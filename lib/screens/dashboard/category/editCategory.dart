


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/category_controller.dart';
import 'package:get/get.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
class EditCategoryScreen extends StatelessWidget {
  final Map<String, dynamic> category; // Brand details to edit
  EditCategoryScreen({required this.category, super.key});

  final CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

  
    // Prepopulate the text field controller and selected logo
    categoryController.edit_nameController.text = category['name'] ?? '';
    categoryController.edit_selectedImage.value = category['imagUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: dark ? Colors.white : Colors.black, // Adjust color for dark and light modes
            size: 30, // Set a larger size for the icon
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TRoundedContainer(
            showBorder: true,
            backgroundColor: dark ? TColors.dark : TColors.light,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Name Input
                  TextField(
                    controller: categoryController.edit_nameController,
                    decoration: InputDecoration(
                      labelText: 'Brand Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Logo Picker
                  GestureDetector(
                    onTap: () => categoryController.pickEditImage(),
                    child: Obx(() {
                      if (categoryController.edit_selectedImage.value.isEmpty) {
                        // Placeholder if no logo is selected or available
                        return Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: dark ? TColors.darkGrey : TColors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: dark ? TColors.light : TColors.darkerGrey,
                                ),
                                const SizedBox(height: 8),
                                const Text('Select Logo'),
                              ],
                            ),
                          ),
                        );
                      } else if (categoryController.edit_selectedImage.value.contains('http')) {
                        // Display from network if the value is a valid URL
                        return Image.network(
                          categoryController.edit_selectedImage.value,
                          
                          fit: BoxFit.fitHeight,
                          color: dark ? TColors.light : TColors.dark
                        );
                      } else {
                        // Display from file if the value is a local file path
                        return Image.file(
                          File(categoryController.edit_selectedImage.value),
                          
                          fit: BoxFit.fitHeight,
                          color: dark ? TColors.light : TColors.dark,
                        );
                      }
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: categoryController.isLoading.value
                              ? null
                              : () {
                                  categoryController.editCategory(
                                    categoryId: category['id'],
                                    newName: categoryController.edit_nameController.text,
                                    newImagePath: categoryController.edit_selectedImage.value,
                                    currentimagUrl: category['imagUrl'],
                                  );
                                },
                          child: Obx(() => categoryController.isLoading.value
                              ? const CircularProgressIndicator()
                              : const Text('Update Category')),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

