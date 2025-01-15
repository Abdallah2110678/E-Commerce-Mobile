import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/controllers/product_controller.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/utils/validators/validation.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/products/product_image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';

class UpdateProductView extends StatefulWidget {
  UpdateProductView({Key? key, required this.product}) : super(key: key);
  final Product product;
  @override
  _UpdateProductViewState createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends State<UpdateProductView> {
  // final _formKey = GlobalKey<FormState>();
  // final _titleController = TextEditingController();
  // final _descriptionController = TextEditingController();
  // final _priceController = TextEditingController();
  // final _discountController = TextEditingController();
  // final _stockController = TextEditingController();

  // String _selectedThumbnail = "";
  // Category? _selectedCategory;
  // Brand? _selectedBrand;
  // bool _isLoading = false;

  // final SupabaseClient _supabase = Supabase.instance.client;

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeForm();
  // }

  // void _initializeForm() {
  //   _titleController.text = widget.product.title;
  //   _descriptionController.text = widget.product.description;
  //   _priceController.text = widget.product.price.toString();
  //   _discountController.text = widget.product.discount.toString();
  //   _stockController.text = widget.product.stock.toString();
  //   _selectedThumbnail = widget.product.thumbnailUrl;
  //   _selectedCategory = widget.product.category;
  //   _selectedBrand = widget.product.brand;
  // }

  // Future<void> _updateProduct() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   if (_selectedThumbnail.isEmpty) {
  //     _showError('Please select a thumbnail image');
  //     return;
  //   }

  //   if (_selectedCategory == null) {
  //     _showError('Please select a category');
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     // Delete old thumbnail from Supabase if it's a new file
  //     if (_selectedThumbnail != widget.product.thumbnailUrl) {
  //       final String fileExtension = path.extension(_selectedThumbnail);
  //       final String uniqueFileName =
  //           'product_images/${DateTime.now().millisecondsSinceEpoch}$fileExtension';
  //       final File imageFile = File(_selectedThumbnail);

  //       await _supabase.storage.from('products').upload(
  //         uniqueFileName,
  //         imageFile,
  //         fileOptions: FileOptions(
  //           contentType: 'image/${fileExtension.substring(1)}',
  //           upsert: true,
  //         ),
  //       );
  //       final String imageUrl =
  //           _supabase.storage.from('products').getPublicUrl(uniqueFileName);
  //       _selectedThumbnail = imageUrl;
  //     }

  //     // Update product in Firestore
  //     final updatedProduct = Product(
  //       id: widget.product.id,
  //       title: _titleController.text.trim(),
  //       description: _descriptionController.text.trim(),
  //       thumbnailUrl: _selectedThumbnail,
  //       price: double.parse(_priceController.text),
  //       discount: double.parse(_discountController.text),
  //       stock: int.parse(_stockController.text),
  //       category: _selectedCategory!,
  //       brand: _selectedBrand!,
  //       imageUrls: widget.product.imageUrls, // Keep existing images
  //     );

  //     await _supabase
  //         .from('products')
  //         .update(updatedProduct.toFirestore())
  //         .eq('id', updatedProduct.id);

  //     _showSuccess('Product updated successfully');
  //     Navigator.pop(context, updatedProduct);
  //   } catch (e) {
  //     _showError('Failed to update product: $e');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _pickThumbnail() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedThumbnail = pickedFile.path;
  //     });
  //   }
  // }

  // void _showError(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  // void _showSuccess(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  // }

  ProductController controller = Get.put(ProductController());

  // Observable values

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
    controller.editTitleController.text = widget.product.title;
    controller.editDescriptionController.text = widget.product.description;
    controller.editPriceController.text = widget.product.price.toString();
    controller.editDiscountController.text = widget.product.discount.toString();
    controller.editStockController.text = widget.product.stock.toString();
    controller.editSelectedThumbnail.value = widget.product.thumbnailUrl;
    controller.editSelectedCategory.value = widget.product.category;
    controller.editSelectedBrand.value = widget.product.brand;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: Form(
        key: controller.formKey,
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
                    controller: controller.editTitleController,
                    decoration: _buildInputDecoration("Product Title"),
                    validator: TValidator.validateNonEmptyField,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: controller.editDescriptionController,
                    maxLines: 5,
                    decoration: _buildInputDecoration("Product Description"),
                    validator: TValidator.validateNonEmptyField,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.categories.isEmpty) {
                      return const Text('No categories available');
                    }

                    return DropdownButtonFormField<Category>(
                      value: controller.editSelectedCategory.value,
                      items: controller.categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.editSelectedCategory.value = value;
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
                    if (controller.brands.isEmpty) {
                      return const Text(
                          'No brands available'); // Display message if no brands
                    }

                    return DropdownButtonFormField<Brand>(
                      value: controller.editSelectedBrand.value,
                      items: controller.brands.map((brand) {
                        return DropdownMenuItem<Brand>(
                          value: brand,
                          child: Text(brand.name), // Display brand name
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.editSelectedBrand.value =
                              value; // Update selected brand
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Brand',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a brand' : null,
                    );
                  }),

                  const SizedBox(height: 15),
                  TextFormField(
                    controller: controller.editPriceController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration("Price"),
                    validator: TValidator.validatePositiveNumber,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: controller.editDiscountController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Discount'),
                    validator: TValidator.validatePercentage,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: controller.editStockController,
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
                          GestureDetector(
                              onTap: controller.editPickThumbnail,
                              child: Obx(() {
                                if (controller
                                    .editSelectedThumbnail.value.isEmpty) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          THelperFunctions.isDarkMode(context)
                                              ? TColors.darkGrey
                                              : TColors.light,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 50,
                                            color: THelperFunctions.isDarkMode(
                                                    context)
                                                ? TColors.dark
                                                : TColors.darkGrey,
                                          ),
                                          SizedBox(height: 8),
                                          Text('Select Thumbnail'),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (controller.editSelectedThumbnail.value
                                    .contains('http')) {
                                  return Image.network(
                                    controller.editSelectedThumbnail.value,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  );
                                } else {
                                return   Image.file(
                                        File(
                                            controller.editSelectedThumbnail.value),
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      );
                                }
                              })),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              :()=> controller.updateProduct(widget.product),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isLoading.value
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
