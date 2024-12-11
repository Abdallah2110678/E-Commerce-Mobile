import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/controllers/product/product_controller.dart';
import 'package:mobile_project/utils/constants/colors.dart';

class AddProductView extends StatefulWidget {
  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  

  final ProductController controller = ProductController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  File? thumbnail;
  List<File> galleryImages = [];

  final ImagePicker picker = ImagePicker();

  // Pick image from gallery
  Future<void> pickImage(bool isThumbnail) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isThumbnail) {
          thumbnail = File(image.path);
        } else {
          galleryImages.add(File(image.path));
        }
      });
    }
  }

  // Submit product data
  Future<void> submitProduct() async {
    if (thumbnail == null || galleryImages.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please upload images')));
      return;
    }

    try {
      await controller.createProduct(
        title: titleController.text,
        description: descriptionController.text,
        thumbnail: thumbnail!,
        images: galleryImages,
        price: double.parse(priceController.text),
        discount: double.parse(discountController.text),
        stock: int.parse(stockController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product created successfully')));
      titleController.text = "";
      descriptionController.text = "";
      priceController.text = "";
      discountController.text = "";
      stockController.text = "";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create product: $e')));
      print(e);
    }
  }

  // ignore: non_constant_identifier_names
  InputDecoration _InputDecoration(title) {
    return InputDecoration(
      labelText: '$title',
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.blue, // Color when focused
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Basic Information",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        controller: titleController,
                        decoration: _InputDecoration("Product Title")),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: _InputDecoration("Product Description"))
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stock and Pricing",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number, // Numeric input
                            decoration: _InputDecoration("Price")),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            controller: discountController,
                            keyboardType: TextInputType.number, // Numeric input
                            decoration: _InputDecoration('Discount')),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            controller: stockController,
                            keyboardType: TextInputType.number, // Numeric input
                            decoration: _InputDecoration('Stock')),
                      ],
                    ))),

            const SizedBox(
              height: 25,
            ),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pick Thumbnail",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () => pickImage(true),
                      child: thumbnail == null
                          ? Container(
                              height: 200,
                              width: 300,
                              color: Colors.grey[300],
                              child: Icon(Icons.add_photo_alternate),
                            )
                          : Image.file(thumbnail!,
                              height: 300, width: 300, fit: BoxFit.cover),
                    )
                  ],
                ),
              ),
            ),
            // Thumbnail picker
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(true),
                  child: Text('Pick Thumbnail'),
                ),
                thumbnail != null ? Text('Thumbnail selected') : Container(),
              ],
            ),

            // Gallery image picker
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(false),
                  child: Text('Pick Gallery Images'),
                ),
                Text('${galleryImages.length} images selected'),
              ],
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitProduct,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
