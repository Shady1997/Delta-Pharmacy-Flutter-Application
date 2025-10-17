class ProductsTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const ProductsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  List<Product> products = [];
  bool loading = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _prescriptionRequired = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => loading = true);
    try {
      final fetchedProducts = await ApiService.getProducts();
      setState(() => products = fetchedProducts);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createProduct() async {
    setState(() => loading = true);
    try {
      final product = await ApiService.createProduct({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stockQuantity': int.parse(_stockController.text),
        'category': _categoryController.text,
        'prescriptionRequired': _prescriptionRequired,
      });
      setState(() => products.add(product));
      _clearForm();
      widget.onMessage('Product created successfully!', false);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteProduct(int id) async {
    setState(() => loading = true);
    try {
      await ApiService.deleteProduct(id);
      setState(() => products.removeWhere((p) => p.id == id));
      widget.onMessage('Product deleted successfully!', false);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _categoryController.clear();
    setState(() => _prescriptionRequired = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCreateProductForm(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildLowStockAlert(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildCreateProductForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.add_circle, size: 20),
              SizedBox(width: 8),
              Text(
                'Add New Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Product Name',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Description',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Price',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Stock Quantity',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              hintText: 'Category',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Prescription Required'),
            value: _prescriptionRequired,
            onChanged: (value) {
              setState(() => _prescriptionRequired = value ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _createProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Add Product'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Low Stock Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Products with low stock will appear here',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() => loading = true);
              try {
                final lowStock = await ApiService.getLowStockProducts();
                setState(() => products = lowStock);
                widget.onMessage('Showing low stock products', false);
              } catch (e) {
                widget.onMessage(e.toString(), true);
              } finally {
                setState(() => loading = false);
              }
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('View Low Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products List (${products.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Prescription')),
                DataColumn(label: Text('Actions')),
              ],
              rows: products
                  .map(
                    (product) => DataRow(
                  cells: [
                    DataCell(Text(product.id.toString())),
                    DataCell(Text(product.name)),
                    DataCell(Text(product.category)),
                    DataCell(Text('\${product.price.toStringAsFixed(2)}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.stockQuantity < 10
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.stockQuantity.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stockQuantity < 10
                                ? Colors.red.shade800
                                : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      product.prescriptionRequired
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.close, color: Colors.red),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ),
                  ],
                ),
              )
                  .toList(),
            ),
          ),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No products found',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
