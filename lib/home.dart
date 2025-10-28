import 'dart:io';

import 'package:flutter/material.dart';

import 'db/db_helper.dart';
import 'edit_product.dart';
import 'model/model.dart';
import 'model/product.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
      _isLoading = false;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }


  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteProduct(product.id!);

      if (product.imagePath != null) {
        final file = File(product.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StoreKeeper',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,

        ),
      ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _searchProducts,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    _searchProducts('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Statistics Card
          if (_products.isNotEmpty)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[400]!, Colors.indigo[600]!],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Products',
                    _products.length.toString(),
                    Icons.inventory,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    'Total Items',
                    _products.fold<int>(0, (sum, p) => sum + p.quantity).toString(),
                    Icons.shopping_cart,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    'Value',
                    '\$${_products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity)).toStringAsFixed(0)}',
                    Icons.attach_money,
                  ),
                ],
              ),
            ),

          // Product List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 100, color: Colors.grey[300]),
                  SizedBox(height: 20),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No products yet'
                        : 'No products found',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Tap + to add your first product'
                        : 'Try a different search',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditProductScreen()),
          );
          _loadProducts();
        },
        icon: Icon(Icons.add,
        color: Colors.white,),
        label: Text('Add Product'
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo[700],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
          _loadProducts();
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: product.imagePath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(product.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 40, color: Colors.grey[400]);
                    },
                  ),
                )
                    : Icon(Icons.inventory_2, size: 40, color: Colors.grey[400]),
              ),
              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Qty: ${product.quantity}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.attach_money, size: 16, color: Colors.green),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.quantity > 10
                            ? Colors.green[50]
                            : product.quantity > 5
                            ? Colors.orange[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.quantity > 10
                            ? 'In Stock'
                            : product.quantity > 5
                            ? 'Low Stock'
                            : 'Very Low',
                        style: TextStyle(
                          fontSize: 10,
                          color: product.quantity > 10
                              ? Colors.green[700]
                              : product.quantity > 5
                              ? Colors.orange[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditProductScreen(product: product),
                        ),
                      );
                      _loadProducts();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
