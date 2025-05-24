import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../components/forms/app_text_field.dart';
import '../../components/buttons/loading_button.dart';
import '../../utils/error_handler.dart';
import '../../providers/product_provider.dart'; // Change path if needed
import '../../models/product.dart';
import 'components/product_image_picker.dart';
import 'components/product_form_section.dart';
import 'components/shipping_info_section.dart';

class ProductEditScreen extends StatefulWidget {
  final String? productId;
  final String vendorId;

  const ProductEditScreen({
    this.productId, 
    required this.vendorId,
    super.key, // Use super parameter
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState(); // Fix return type
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  File? _productImage;
  bool _isLoading = false;
  bool _isLoadingProduct = false;
  Product? _product;
  Map<String, dynamic> _shippingInfo = {};

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Fix BuildContext across async gap
  Future<void> _loadProductDetails() async {
    if (widget.productId == null) return;
    
    setState(() {
      _isLoadingProduct = true;
    });
    
    await ErrorHandler.handleFuture<void>(
      context,
      Future(() async {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        final productDoc = await productProvider.getProductById(widget.productId!);
        
        if (productDoc != null) {
          setState(() {
            _product = productDoc;
            _nameController.text = _product!.name;
            _descriptionController.text = _product!.description;
            _priceController.text = _product!.price.toString();
            _quantityController.text = _product!.quantity.toString();
            if (_product!.postageInfo != null) {
              _shippingInfo = _product!.postageInfo!;
            }
          });
        }
      }),
      errorMessage: 'Failed to load product details',
      onError: () {
        if (mounted) { // Add mounted check
          Navigator.pop(context);
        }
      },
    );
    
    if (mounted) { // Add mounted check
      setState(() {
        _isLoadingProduct = false;
      });
    }
  }

  void _onShippingInfoChanged(Map<String, dynamic> shippingInfo) {
    setState(() {
      _shippingInfo = shippingInfo;
    });
  }

  void _onImagePicked(File image) {
    setState(() {
      _productImage = image;
    });
  }

  // Fix BuildContext across async gap for _saveProduct
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    await ErrorHandler.handleFuture<void>(
      context,
      Future(() async {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        
        final productData = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'quantity': int.parse(_quantityController.text),
          'vendorId': widget.vendorId,
          'postageInfo': _shippingInfo,
          'createdAt': DateTime.now(),
        };
        
        if (widget.productId != null) {
          // Update existing product
          await productProvider.updateProduct(widget.productId!, productData, _productImage);
          
          if (mounted) { // Add mounted check
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully')),
            );
          }
        } else {
          // Create new product
          await productProvider.createProduct(productData, _productImage);
          
          if (mounted) { // Add mounted check
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product created successfully')),
            );
          }
        }
        
        if (!mounted) return;
        Navigator.pop(context);
      }),
      errorMessage: 'Failed to save product',
    );
    
    if (mounted) { // Add mounted check
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: _isLoadingProduct 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImagePicker(
                    initialImageUrl: _product?.imageUrl,
                    onImagePicked: _onImagePicked,
                  ),
                  const SizedBox(height: 16),
                  
                  ProductFormSection(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    quantityController: _quantityController,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  ShippingInfoSection(
                    initialShippingInfo: _shippingInfo,
                    onShippingInfoChanged: _onShippingInfoChanged,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  LoadingButton(
                    text: widget.productId != null ? 'Update Product' : 'Create Product',
                    isLoading: _isLoading,
                    onPressed: _saveProduct,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
