import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/brand_controller.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';

class EditBrandScreen extends StatelessWidget {
  final Map<String, dynamic> brand; // Brand details to edit
  EditBrandScreen({required this.brand, super.key});

  final BrandController brandController = Get.put(BrandController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    
    brandController.edit_nameController.text = brand['name'] ?? '';
    brandController.edit_selectedLogo.value = brand['logoUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Brand"),
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
                    controller: brandController.edit_nameController,
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
                    onTap: () => brandController.pickEditLogo(),
                    child: Obx(() {
                      if (brandController.edit_selectedLogo.value.isEmpty) {
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
                      } else if (brandController.edit_selectedLogo.value.contains('http')) {
                        // Display from network if the value is a valid URL
                        return Image.network(
                          brandController.edit_selectedLogo.value,
                          
                          fit: BoxFit.fitHeight,
                          color: dark ? TColors.light : TColors.dark
                        );
                      } else {
                        // Display from file if the value is a local file path
                        return Image.file(
                          File(brandController.edit_selectedLogo.value),
                          
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
                          onPressed: brandController.isLoading.value
                              ? null
                              : () {
                                  brandController.editBrand(
                                    brandId: brand['id'],
                                    newName: brandController.edit_nameController.text,
                                    newLogoPath: brandController.edit_selectedLogo.value,
                                    currentLogoUrl: brand['logoUrl'],
                                  );
                                },
                          child: Obx(() => brandController.isLoading.value
                              ? const CircularProgressIndicator()
                              : const Text('Update Brand')),
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