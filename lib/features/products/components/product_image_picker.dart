import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File) onImagePicked;

  const ProductImagePicker({
    Key? key,
    this.initialImageUrl,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  _ProductImagePickerState createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      widget.onImagePicked(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Image',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                : widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
                    ? Image.network(
                        widget.initialImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}