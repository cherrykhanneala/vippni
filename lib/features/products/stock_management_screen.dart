import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../repositories/stock_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
    });
  }

  Future<void> _fetchProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts();
  }

  Future<void> _updateStock(String productId, int newQuantity) async {
    setState(() => _isLoading = true);
    
    try {
      final stockRepo = Provider.of<StockRepository>(context, listen: false);
      await stockRepo.updateStock(productId, newQuantity);
      
      // Record the stock movement
      await stockRepo.recordStockMovement(
        productId, 
        newQuantity > 0 ? 'in' : 'out', 
        newQuantity, 
        'Manual stock adjustment'
      );
      
      await _fetchProducts(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stock: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        backgroundColor: const Color(0xFF31135F),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final products = productProvider.products;
          
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          
          return RefreshIndicator(
            onRefresh: _fetchProducts,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index].data() as Map<String, dynamic>;
                final currentQuantity = product['quantity'] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: product['images'] != null &&
                            (product['images'] as List).isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              product['images'][0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.inventory),
                    title: Text(product['name'] ?? 'Unnamed Product'),
                    subtitle: Text('Current Stock: $currentQuantity'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: currentQuantity > 0
                              ? () => _updateStock(
                                    products[index].id,
                                    currentQuantity - 1,
                                  )
                              : null,
                        ),
                        Text('$currentQuantity'),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () => _updateStock(
                            products[index].id,
                            currentQuantity + 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
