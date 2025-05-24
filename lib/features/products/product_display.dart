import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDisplay extends StatefulWidget {
  final String productId;
  final String backButtonLabel;

  const ProductDisplay({
    required this.productId,
    this.backButtonLabel = 'Back to Products',
    super.key,
  });

  @override
  ProductDisplayState createState() => ProductDisplayState();
}

class ProductDisplayState extends State<ProductDisplay> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _productFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _productFuture = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
  }

  Future<void> _deleteProduct() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .delete();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(); // Go back to products list
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editProduct() {
    final String vendorId = FirebaseAuth.instance.currentUser!.uid;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditScreen(
          productId: widget.productId,
          vendorId: vendorId,
        ),
      ),
    ).then((_) {
      // Refresh the product data when returning from edit screen
      setState(() {
        _productFuture = FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: const Color(0xFF31135F),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // Edit button
          IconButton(
            onPressed: _editProduct,
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Product',
          ),
          // Delete button
          IconButton(
            onPressed: _isDeleting ? null : _deleteProduct,
            icon: _isDeleting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Delete Product',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error fetching product data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Product not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final productData = snapshot.data!.data()!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: _buildProductDetails(productData),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: Text(
                  widget.backButtonLabel,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31135F),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _editProduct,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Edit Product',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isDeleting ? null : _deleteProduct,
                icon: _isDeleting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.delete, color: Colors.white),
                label: Text(
                  _isDeleting ? 'Deleting...' : 'Delete',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Map<String, dynamic> productData) {
    // Extract fields from productData
    final String name = productData['name'] ?? '';
    final String description = productData['description'] ?? '';
    final double price = (productData['price'] as num?)?.toDouble() ?? 0.0;
    final double? rrp = (productData['rrp'] as num?)?.toDouble();
    final double? salePrice = (productData['salePrice'] as num?)?.toDouble();
    final bool isOnSale = productData['isOnSale'] ?? false;
    final int quantity = productData['quantity'] ?? 0;
    final String barcode = productData['barcode'] ?? '';
    final String type = productData['type'] ?? '';
    final String availability = productData['availability'] ?? '';
    final double weight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
    final String weightUnit = productData['weightUnit'] ?? '';
    final String dimensions = productData['dimensions'] ?? '';
    final String dimensionsUnit = productData['dimensionsUnit'] ?? '';
    final String packaging = productData['packaging'] ?? '';
    final List<dynamic> materials = productData['material'] ?? [];
    final List<dynamic> colors = productData['colors'] ?? [];
    final List<dynamic> tags = productData['tags'] ?? [];
    final List<dynamic> images = productData['images'] ?? [];

    final bool isLowStock = quantity <= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Images
        if (images.isNotEmpty)
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: images[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 80,
                color: Colors.grey,
              ),
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Product Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF31135F),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Product Type
        if (type.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF31135F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              type,
              style: const TextStyle(
                color: Color(0xFF31135F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Price Section
        Row(
          children: [
            Text(
              'Rs.${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isOnSale ? Colors.red : Colors.green.shade800,
              ),
            ),
            if (rrp != null && rrp > price) ...[
              const SizedBox(width: 8),
              Text(
                'Rs.${rrp.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
            if (isOnSale) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SALE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Stock Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLowStock ? Colors.red.shade200 : Colors.green.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: isLowStock ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Stock: $quantity',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLowStock ? Colors.red.shade800 : Colors.green.shade800,
                ),
              ),
              if (isLowStock) ...[
                const SizedBox(width: 8),
                Text(
                  '(Low Stock)',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Description
        if (description.isNotEmpty) ...[
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF31135F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Additional Details
        _buildDetailCard('Product Details', [
          if (barcode.isNotEmpty) _buildDetailRow('Barcode', barcode),
          _buildDetailRow('Availability', availability),
          if (weight > 0) _buildDetailRow('Weight', '$weight $weightUnit'),
          if (dimensions.isNotEmpty) _buildDetailRow('Dimensions', '$dimensions $dimensionsUnit'),
          if (packaging.isNotEmpty) _buildDetailRow('Packaging', packaging),
        ]),
        
        if (materials.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailCard('Materials', [
            _buildChipRow('Materials', materials.cast<String>()),
          ]),
        ],
        
        if (colors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailCard('Colors', [
            _buildChipRow('Colors', colors.cast<String>()),
          ]),
        ],
        
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailCard('Tags', [
            _buildChipRow('Tags', tags.cast<String>()),
          ]),
        ],
        
        const SizedBox(height: 80), // Space for bottom buttons
      ],
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF31135F),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(
              item,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF31135F).withOpacity(0.1),
            labelStyle: const TextStyle(
              color: Color(0xFF31135F),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
