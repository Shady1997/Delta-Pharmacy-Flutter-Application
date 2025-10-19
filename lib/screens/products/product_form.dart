import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class ProductForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const ProductForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _manufacturerController = TextEditingController();
  String _selectedCategory = AppConfig.productCategories[0];
  bool _prescriptionRequired = false;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stockQuantity': int.parse(_stockController.text),
        'category': _selectedCategory,
        'prescriptionRequired': _prescriptionRequired,
        'manufacturer': _manufacturerController.text,
      });
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _manufacturerController.clear();
    setState(() {
      _selectedCategory = AppConfig.productCategories[0];
      _prescriptionRequired = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stock is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              items: AppConfig.productCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Manufacturer (Optional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Prescription Required'),
              subtitle: const Text('Check if this product requires prescription'),
              value: _prescriptionRequired,
              onChanged: (value) {
                setState(() => _prescriptionRequired = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Add Product'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}