import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/product_card.dart';
import '../../widgets/products_menu.dart';
import 'product_display.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendorId = FirebaseAuth.instance.currentUser!.uid;

  // Pagination variables
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  final List<QueryDocumentSnapshot> _products = [];

  // Filter variable
  String _currentFilter = 'uploads';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchProducts({bool isRefresh = false}) async {
    if (_isLoadingMore) return;

    if (isRefresh) {
      _lastDocument = null;
      _hasMore = true;
      _products.clear();
    }

    if (!_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Query query = _firestore
          .collection('products')
          .where('userId', isEqualTo: _vendorId) // Use userId instead of vendorId
          .orderBy('name')
          .limit(_limit);

      // Apply filter
      query = _applyFilter(query);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        setState(() {
          _products.addAll(querySnapshot.docs);
        });
      } else {
        _hasMore = false;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Query _applyFilter(Query query) {
    switch (_currentFilter) {
      case 'uploads':
        return query;
      case 'under_review':
        return query.where('status', isEqualTo: 'under_review');
      case 'sold':
        return query.where('status', isEqualTo: 'sold');
      case 'on_sale':
        return query.where('status', isEqualTo: 'on_sale');
      case 'in_process':
        return query.where('status', isEqualTo: 'in_process');
      case 'cancelled':
        return query.where('status', isEqualTo: 'cancelled');
      case 'inventory':
        return query;
      default:
        return query;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchProducts();
    }
  }

  Future<void> _onRefresh() async {
    await _fetchProducts(isRefresh: true);
  }

  void _onMenuItemSelected(String menuOption) {
    setState(() {
      _currentFilter = menuOption;
    });
    _onRefresh();
  }

  void _navigateToProductDisplay(DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDisplay(
          productId: product.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF31135F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: ProductsMenu(
        onMenuItemSelected: _onMenuItemSelected,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _products.isEmpty && !_isLoadingMore
            ? const Center(
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
                      'No products found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your first product to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Adjusted aspect ratio
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _products.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _products.length) {
                    final product = _products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _navigateToProductDisplay(product),
                    );
                  } else {
                    return const Card(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
