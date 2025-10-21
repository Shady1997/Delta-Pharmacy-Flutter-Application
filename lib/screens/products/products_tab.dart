import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../products/product_form.dart';
import '../products/product_details_page.dart';

class ProductsTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const ProductsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _filterCategory = 'All';
  bool _showPrescriptionOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      widget.onMessage('Failed to load products: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final matchesCategory =
            _filterCategory == 'All' || product.category == _filterCategory;
        final matchesPrescription =
            !_showPrescriptionOnly || product.prescriptionRequired;
        return matchesSearch && matchesCategory && matchesPrescription;
      }).toList();
    });
  }

  Future<void> _createProduct(Map<String, dynamic> productData) async {
    try {
      await ApiService.createProduct(productData);
      widget.onMessage('Product created successfully', false);
      _loadProducts();
    } catch (e) {
      widget.onMessage('Failed to create product: ${e.toString()}', true);
    }
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteProduct(id);
        widget.onMessage('Product deleted successfully', false);
        _loadProducts();
      } catch (e) {
        widget.onMessage('Failed to delete product: ${e.toString()}', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ListView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products Management',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.isCustomer == true
                        ? 'Browse available medicines'
                        : 'Manage inventory and products',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Create Product Form (Admin only)
        if (user?.canManageProducts() == true) ...[
          ProductForm(onSubmit: _createProduct),
          const SizedBox(height: 16),
        ],

        // Search and Filter
        if (isMobile) ...[
          // Mobile: Stack filters vertically
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: ['All', 'Antibiotics', 'Pain Relief', 'Vitamins', 'Cold & Flu', 'Other']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category, style: const TextStyle(fontSize: 13)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _filterCategory = value!);
                    _filterProducts();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showPrescriptionOnly,
                      onChanged: (value) {
                        setState(() => _showPrescriptionOnly = value!);
                        _filterProducts();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text('Rx', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Desktop: Horizontal layout
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: ['All', 'Antibiotics', 'Pain Relief', 'Vitamins', 'Cold & Flu', 'Other']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _filterCategory = value!);
                    _filterProducts();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _showPrescriptionOnly,
                      onChanged: (value) {
                        setState(() => _showPrescriptionOnly = value!);
                        _filterProducts();
                      },
                    ),
                    const Text('Rx Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // Products Table
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Products (${_filteredProducts.length})',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _filteredProducts.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No products found'),
                ),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.blue.shade100,
                  ),
                  columnSpacing: isMobile ? 20 : 56,
                  horizontalMargin: isMobile ? 8 : 24,
                  dataRowHeight: isMobile ? 48 : 56,
                  headingRowHeight: isMobile ? 40 : 56,
                  columns: [
                    DataColumn(label: Text('ID', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                    DataColumn(label: Text('Name', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                    DataColumn(label: Text('Category', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                    DataColumn(label: Text('Price', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                    DataColumn(label: Text('Stock', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                    DataColumn(label: Text('Rx', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                    if (user?.canManageProducts() == true)
                      DataColumn(label: Text('Actions', style: TextStyle(fontSize: isMobile ? 12 : 14))),
                  ],
                  rows: _filteredProducts.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(Text(product.id.toString(), style: TextStyle(fontSize: isMobile ? 11 : 13))),
                        DataCell(
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsPage(product: product),
                                ),
                              );
                            },
                            child: Text(
                              product.name,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: isMobile ? 11 : 13,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(product.category, style: TextStyle(fontSize: isMobile ? 11 : 13))),
                        DataCell(Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: isMobile ? 11 : 13))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.stockQuantity < 10
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.stockQuantity.toString(),
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                                color: product.stockQuantity < 10
                                    ? Colors.red.shade800
                                    : Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          product.prescriptionRequired
                              ? const Icon(Icons.check,
                              color: Colors.green, size: 20)
                              : const Icon(Icons.close,
                              color: Colors.red, size: 20),
                        ),
                        if (user?.canManageProducts() == true)
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () =>
                                  _deleteProduct(product.id),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Low Stock Alert (Admin/Pharmacist only)
        if (user?.canViewAnalytics() == true && _filteredProducts.any((p) => p.stockQuantity < 10)) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Low Stock Alert',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._filteredProducts
                    .where((p) => p.stockQuantity < 10)
                    .map((product) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle,
                          size: 8, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${product.name} - Only ${product.stockQuantity} left',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}