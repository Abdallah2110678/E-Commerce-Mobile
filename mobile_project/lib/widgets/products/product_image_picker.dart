
import 'package:flutter/material.dart';

class ProductImagePicker extends StatefulWidget {
  final Function(String) onThumbnailSelected;
  final Function(List<String>) onImagesSelected;
  final bool isThumbnailPicker;
  final List<String> selectedImages;

  const ProductImagePicker({
    super.key,
    required this.onThumbnailSelected,
    required this.onImagesSelected,
    required this.isThumbnailPicker,
    required this.selectedImages,
  });

  @override
  State<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  List<String> tempSelectedImages = [];

  @override
  void initState() {
    super.initState();
    tempSelectedImages = List.from(widget.selectedImages);
  }

  final List<String> availableImages = [
    'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
    'https://static.vecteezy.com/ti/photos-gratuite/t2/48021360-colore-lezard-dans-neon-couleurs-fonce-contexte-avec-une-fermer-photo.jpg',
    'https://img.freepik.com/photos-gratuite/gros-plan-iguane-dans-nature_23-2151718784.jpg',
    'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
    'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
  ];

  void _toggleImageSelection(String imagePath) {
    setState(() {
      if (widget.isThumbnailPicker) {
        tempSelectedImages = [imagePath];
      } else {
        if (tempSelectedImages.contains(imagePath)) {
          tempSelectedImages.remove(imagePath);
        } else {
          tempSelectedImages.add(imagePath);
        }
      }
    });
  }

  void _confirmSelection() {
    if (widget.isThumbnailPicker && tempSelectedImages.isNotEmpty) {
      widget.onThumbnailSelected(tempSelectedImages.first);
    } else {
      widget.onImagesSelected(tempSelectedImages);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isThumbnailPicker
                      ? 'Select Thumbnail'
                      : 'Select Images',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: _confirmSelection,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableImages.length,
                itemBuilder: (context, index) {
                  final imagePath = availableImages[index];
                  final isSelected = tempSelectedImages.contains(imagePath);

                  return GestureDetector(
                    onTap: () => _toggleImageSelection(imagePath),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _toggleImageSelection(imagePath),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}