import 'package:flutter/material.dart';
import '../../../components/forms/app_text_field.dart';
import '../../../utils/validators.dart';

class ProductFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  const ProductFormSection({
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.quantityController,
    super.key, // Use super parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: nameController,
          label: 'Product Name',
          hint: 'Enter product name',
          isRequired: true, onChanged: (value) {  },
        ),
        
        AppTextField(
          controller: descriptionController,
          label: 'Description',
          hint: 'Enter product description',
          isRequired: true, onChanged: (value) {  },
        ),
        
        AppTextField(
          controller: priceController,
          label: 'Price',
          hint: 'Enter price',
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: Validators.price, onChanged: (value) {  }, // Change from validatePrice to price
        ),
        
        AppTextField(
          controller: quantityController,
          label: 'Quantity',
          hint: 'Enter quantity',
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: Validators.integer, onChanged: (value) {  }, // Change from validateInteger to integer
        ),
      ],
    );
  }
}