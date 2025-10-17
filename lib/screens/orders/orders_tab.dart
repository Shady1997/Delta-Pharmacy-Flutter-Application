class OrdersTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const OrdersTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<Order> orders = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => loading = true);
    try {
      final fetchedOrders = await ApiService.getOrders();
      setState(() => orders = fetchedOrders);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _updateOrderStatus(int id, String status) async {
    setState(() => loading = true);
    try {
      await ApiService.updateOrderStatus(id, status);
      await _loadOrders();
      widget.onMessage('Order status updated!', false);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Orders Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders List (${orders.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                    columns: const [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('User ID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Total Amount')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: orders
                        .map(
                          (order) => DataRow(
                        cells: [
                          DataCell(Text(order.id.toString())),
                          DataCell(Text(order.userId.toString())),
                          DataCell(Text(order.orderDate.split('T')[0])),
                          DataCell(Text('\${order.totalAmount.toStringAsFixed(2)}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            PopupMenuButton<String>(
                              onSelected: (status) =>
                                  _updateOrderStatus(order.id, status),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'PENDING',
                                  child: Text('Set Pending'),
                                ),
                                const PopupMenuItem(
                                  value: 'PROCESSING',
                                  child: Text('Set Processing'),
                                ),
                                const PopupMenuItem(
                                  value: 'SHIPPED',
                                  child: Text('Set Shipped'),
                                ),
                                const PopupMenuItem(
                                  value: 'DELIVERED',
                                  child: Text('Set Delivered'),
                                ),
                                const PopupMenuItem(
                                  value: 'CANCELLED',
                                  child: Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No orders found',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'SHIPPED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}