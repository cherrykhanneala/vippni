import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final QueryDocumentSnapshot product;
  final VoidCallback? onTap;
  
  const ProductCard({
    required this.product, 
    this.onTap,
    Key? key
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unnamed Product';
    final price = data['price'] ?? 0.0;
    final quantity = data['quantity'] ?? 0;
    
    // Handle both possible image field names
    final imageUrl = data['imageUrl'] ?? 
                    (data['images'] is List && (data['images'] as List).isNotEmpty 
                     ? (data['images'] as List)[0] 
                     : null);
    
    final isLowStock = quantity <= 5;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Fixed height
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  child: imageUrl != null 
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error, size: 30, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name - limit to 2 lines
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Price
                    Text(
                      'Rs.${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Inventory section
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 14,
                          color: isLowStock ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Stock: $quantity',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.grey.shade700,
                              fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}