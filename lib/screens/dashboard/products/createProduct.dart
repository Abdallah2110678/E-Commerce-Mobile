import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/category_controller.dart';
import 'package:mobile_project/controllers/product_controller.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/utils/validators/validation.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/products/product_image_picker.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  ProductController _productController = Get.put(ProductController());

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _productController.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TRoundedContainer(
            showBorder: true,
            backgroundColor: THelperFunctions.isDarkMode(context)
                ? TColors.dark
                : TColors.light,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Product Information",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _productController.titleController,
                    decoration: _buildInputDecoration("Product Title"),
                    validator: TValidator.validateNonEmptyField,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _productController.descriptionController,
                    maxLines: 5,
                    decoration: _buildInputDecoration("Product Description"),
                    validator: TValidator.validateNonEmptyField,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (_productController.categories.isEmpty) {
                      return Text('No categories available');
                    }

                    return DropdownButtonFormField<Category>(
                      value: _productController.selectedCategory.value,
                      items: _productController.categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _productController.selectedCategory.value = value;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    );
                  }),

                  const SizedBox(height: 15),
                  Obx(() {
  if (_productController.brands.isEmpty) {
    return Text('No brands available'); // Display message if no brands
  }

  return DropdownButtonFormField<Brand>(
    value: _productController.selectedBrand.value,
    items: _productController.brands.map((brand) {
      return DropdownMenuItem<Brand>(
        value: brand,
        child: Text(brand.name), // Display brand name
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        _productController.selectedBrand.value = value; // Update selected brand
      }
    },
    decoration: InputDecoration(
      labelText: 'Select Brand',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    validator: (value) => value == null ? 'Please select a brand' : null,
  );
}),

                    const SizedBox(height: 15),
                  TextFormField(
                    controller: _productController.priceController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration("Price"),
                    validator: TValidator.validatePositiveNumber,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _productController.discountController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Discount'),
                    validator: TValidator.validatePercentage,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _productController.stockController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Stock'),
                    validator: TValidator.validateNonNegativeInteger,
                  ),
                  const SizedBox(height: 15),
                  // Thumbnail Section
                  TRoundedContainer(
                    showBorder: true,
                    backgroundColor: THelperFunctions.isDarkMode(context)
                        ? TColors.dark
                        : TColors.light,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              "Product Thumbnail",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(() => GestureDetector(
                                onTap: _productController.pickThumbnail,
                                child: _productController
                                        .selectedThumbnail.value.isEmpty
                                    ? Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: THelperFunctions.isDarkMode(
                                                  context)
                                              ? TColors.darkGrey
                                              : TColors.light,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 50,
                                                color:
                                                    THelperFunctions.isDarkMode(
                                                            context)
                                                        ? TColors.dark
                                                        : TColors.darkGrey,
                                              ),
                                              SizedBox(height: 8),
                                              Text('Select Thumbnail'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Image.file(
                                        File(_productController
                                            .selectedThumbnail.value) ,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                          onPressed: _productController.isLoading.value
                              ? null
                              : _productController.submitProduct,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _productController.isLoading.value
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Submit Product',
                                  style: TextStyle(fontSize: 16),
                                ),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
