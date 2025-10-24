import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../../models/payment.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import '../orders/order_details_page.dart';
import '../payments/payment_dialog.dart';


class OrdersTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const OrdersTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<Order> _orders = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  final _addressController = TextEditingController();
  int _selectedProductId = 1;
  int _quantity = 1;
  String _paymentMethod = 'Credit Card';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final user = ApiService.currentUser;
      if (user == null) return;

      List<Order> orders;
      if (user.canViewAllOrders()) {
        orders = await ApiService.getOrders();
      } else {
        orders = await ApiService.getUserOrders(user.id);
      }

      setState(() => _orders = orders);
    } catch (e) {
      widget.onMessage('Failed to load orders: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createOrder() async {
    final user = ApiService.currentUser;
    if (user == null) {
      widget.onMessage('Please login first', true);
      return;
    }

    if (_addressController.text.isEmpty) {
      widget.onMessage('Please enter shipping address', true);
      return;
    }

    if (_selectedProductId <= 0 || _quantity <= 0) {
      widget.onMessage('Please enter valid product ID and quantity', true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderData = {
        'userId': user.id,
        'items': [
          {
            'productId': _selectedProductId,
            'quantity': _quantity,
          }
        ],
        'shippingAddress': _addressController.text,
        'paymentMethod': _paymentMethod,
      };

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/orders'),
        headers: ApiService.getHeaders(),
        body: json.encode(orderData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);

          // Check payment method - only show payment dialog for card payments
          if (_paymentMethod == 'Credit Card' || _paymentMethod == 'Debit Card') {
            // Show payment dialog for card payments
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => PaymentDialog(
                  orderId: order.id,
                  userId: user.id,
                  amount: order.totalAmount,
                  onSuccess: (payment) {
                    widget.onMessage(
                      'Order placed and payment successful! Transaction: ${payment.transactionId}',
                      false,
                    );
                    _clearForm();
                    _loadOrders();
                  },
                  onError: (error) {
                    widget.onMessage('Payment failed: $error', true);
                  },
                ),
              );
            }
          } else {
            // Cash on Delivery - no payment dialog needed
            widget.onMessage(
              'Order placed successfully! Order will remain PENDING until payment is confirmed.',
              false,
            );
            _clearForm();
            _loadOrders();
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to create order');
        }
      } else if (response.statusCode == 400) {
        // Handle prescription required error
        String errorMsg = data['message'] ?? 'Bad request';
        if (errorMsg.contains('prescription')) {
          widget.onMessage(
            'This product requires a prescription. Please upload and get approval for a prescription first, or use Product ID 1 (Paracetamol) which doesn\'t require prescription.',
            true,
          );
        } else {
          widget.onMessage(errorMsg, true);
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      widget.onMessage('Failed to create order: ${e.toString()}', true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _addressController.clear();
    setState(() {
      _selectedProductId = 1;
      _quantity = 1;
      _paymentMethod = 'Cash on Delivery';
    });
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
      widget.onMessage('Order status updated successfully', false);
      _loadOrders();
    } catch (e) {
      widget.onMessage('Failed to update order: ${e.toString()}', true);
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
                    user?.canViewAllOrders() == true
                        ? 'Orders Management'
                        : 'My Orders',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.canViewAllOrders() == true
                        ? 'View and manage all customer orders'
                        : 'Track your order history',
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

        // Search
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search orders by ID or address...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Create Order Form (Customer only)
        // Create Order Form (Customer only)
        if (user?.isCustomer == true) ...[
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_shopping_cart, color: Colors.orange.shade700, size: isMobile ? 18 : 20),
                    const SizedBox(width: 8),
                    Text(
                      'Create New Order',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Use Product ID 1 (Paracetamol 500mg) - no prescription required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Product Selection
                if (isMobile) ...[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Product ID',
                      hintText: 'Enter product ID (e.g., 1)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                      helperText: 'ID 1: Paracetamol (no Rx), ID 2: Amoxicillin (needs Rx)',
                      helperMaxLines: 2,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _quantity = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Product ID',
                            hintText: 'Enter product ID (e.g., 1)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            helperText: 'ID 1: Paracetamol (no Rx required)',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _selectedProductId = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            hintText: 'Enter quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _quantity = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Shipping Address
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Shipping Address',
                    hintText: 'Enter delivery address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Payment Method
                // Payment Method
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    prefixIcon: const Icon(Icons.payment),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Cash on Delivery',
                      child: Row(
                        children: [
                          Icon(Icons.money, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text('Cash on Delivery'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Credit Card',
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text('Credit Card'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Debit Card',
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text('Debit Card'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _paymentMethod = value!);
                  },
                ),
                const SizedBox(height: 12),

// Payment Info Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'Cash on Delivery'
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _paymentMethod == 'Cash on Delivery'
                          ? Colors.green.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _paymentMethod == 'Cash on Delivery' ? Icons.info : Icons.credit_card,
                        color: _paymentMethod == 'Cash on Delivery'
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _paymentMethod == 'Cash on Delivery'
                              ? 'Pay when you receive your order. Order status will remain PENDING until payment confirmed.'
                              : 'You will be asked to enter your card details after creating the order.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _paymentMethod == 'Cash on Delivery'
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Create Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createOrder,
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Create Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Orders List
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
                'Orders (${_orders.length})',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _orders.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No orders found'),
                ),
              )
                  : isMobile
                  ? Column(
                children: _orders.map((order) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Text(
                                  order.id.toString(),
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${order.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '\$${order.totalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.deliveryAddress,
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: StatusBadge(
                                            status: order.status,
                                            type: 'order',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            DateFormatter.formatDate(order.orderDate),
                                            style: const TextStyle(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (user?.canUpdateOrderStatus() == true)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  padding: EdgeInsets.zero,
                                  onSelected: (status) => _updateOrderStatus(order.id, status),
                                  itemBuilder: (context) => [
                                    'PENDING',
                                    'PROCESSING',
                                    'SHIPPED',
                                    'DELIVERED',
                                    'CANCELLED'
                                  ]
                                      .map((status) => PopupMenuItem(
                                    value: status,
                                    child: Text(status,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                                      .toList(),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.visibility, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailsPage(order: order),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.orange.shade100,
                  ),
                  columns: [
                    const DataColumn(label: Text('Order ID')),
                    if (user?.canViewAllOrders() == true)
                      const DataColumn(label: Text('User ID')),
                    const DataColumn(label: Text('Date')),
                    const DataColumn(label: Text('Total')),
                    const DataColumn(label: Text('Status')),
                    const DataColumn(label: Text('Address')),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: _orders.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailsPage(order: order),
                                ),
                              );
                            },
                            child: Text(
                              order.id.toString(),
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (user?.canViewAllOrders() == true)
                          DataCell(Text(order.userId.toString())),
                        DataCell(Text(
                            DateFormatter.formatDate(order.orderDate))),
                        DataCell(Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}')),
                        DataCell(
                          StatusBadge(
                            status: order.status,
                            type: 'order',
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              order.deliveryAddress,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          user?.canUpdateOrderStatus() == true
                              ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (status) =>
                                _updateOrderStatus(
                                    order.id, status),
                            itemBuilder: (context) => [
                              'PENDING',
                              'PROCESSING',
                              'SHIPPED',
                              'DELIVERED',
                              'CANCELLED'
                            ]
                                .map((status) => PopupMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                                .toList(),
                          )
                              : IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailsPage(
                                          order: order),
                                ),
                              );
                            },
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
      ],
    );
  }
}