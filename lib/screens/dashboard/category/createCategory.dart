

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/category_controller.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:get/get.dart';
class CreateCategoryScreen extends StatelessWidget {
  CreateCategoryScreen({super.key});

  final CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Category"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: dark
                ? Colors.white
                : Colors.black, // Adjust color for dark and light modes
            size: 30, // Set a larger size for the icon
          ),
          onPressed: () {
            categoryController.clearInputs();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TRoundedContainer(
            showBorder: true,
            backgroundColor: THelperFunctions.isDarkMode(context)
                ? TColors.dark
                : TColors.light,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Name Input
                  TextField(
                    controller: categoryController.nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Logo Picker
                  GestureDetector(
                    onTap: () => categoryController.pickImage(),
                    child: Obx(() {
                      return categoryController.selectedImage.value.isEmpty
                          ? Container(
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
                                    Icon(Icons.add_photo_alternate,
                                        size: 50,
                                        color: dark
                                            ? TColors.dark
                                            : TColors.darkerGrey),
                                    const SizedBox(height: 8),
                                    const Text('Select Logo'),
                                  ],
                                ),
                              ),
                            )
                          : Image.file(
                              File(categoryController.selectedImage.value),
                              fit: BoxFit.fitHeight,
                              color: dark ? TColors.light : TColors.dark,
                            );
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
                              : categoryController.saveCategory,
                          child: Obx(() => categoryController.isLoading.value
                              ? const CircularProgressIndicator()
                              : const Text('Save Category')),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Clear inputs and navigate back
                            categoryController.clearInputs();
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
