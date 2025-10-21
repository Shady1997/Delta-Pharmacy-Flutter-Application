import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class AnalyticsTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const AnalyticsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  bool _isLoading = false;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final user = ApiService.currentUser;

    if (user?.canViewAnalytics() != true) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final analytics = await ApiService.getAnalytics();
      setState(() {
        _analytics = analytics;
      });
    } catch (e) {
      widget.onMessage('Failed to load analytics: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _getIntValue(Map<String, dynamic>? map, String key) {
    if (map == null) return 0;
    final value = map[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  double _getDoubleValue(Map<String, dynamic>? map, String key) {
    if (map == null) return 0.0;
    final value = map[key];
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (user?.canViewAnalytics() != true) {
      return Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(Icons.lock, size: 64, color: Colors.grey.shade400),
    const SizedBox(height: 16),
    const Text(
    'Access Denied',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
            const SizedBox(height: 8),
            Text(
              'Analytics are only available for Admin and Pharmacist roles',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
          ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Reports',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Business insights and performance metrics',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAnalytics,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          // Sales Report
          _buildReportCard(
            'Sales Report',
            [
              _buildMetricRow(
                'Total Revenue',
                '\$${_getDoubleValue(_analytics['sales'] as Map<String, dynamic>?, 'totalRevenue').toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
                isMobile,
              ),
              _buildMetricRow(
                'Total Orders',
                _getIntValue(_analytics['sales'] as Map<String, dynamic>?, 'totalOrders').toString(),
                Icons.shopping_bag,
                Colors.blue,
                isMobile,
              ),
              _buildMetricRow(
                'Average Order Value',
                '\$${_getDoubleValue(_analytics['sales'] as Map<String, dynamic>?, 'averageOrderValue').toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.purple,
                isMobile,
              ),
              _buildMetricRow(
                'Pending Orders',
                _getIntValue(_analytics['sales'] as Map<String, dynamic>?, 'pendingOrders').toString(),
                Icons.pending,
                Colors.orange,
                isMobile,
              ),
              _buildMetricRow(
                'Completed Orders',
                _getIntValue(_analytics['sales'] as Map<String, dynamic>?, 'completedOrders').toString(),
                Icons.check_circle,
                Colors.green,
                isMobile,
              ),
            ],
            Colors.green,
            isMobile,
          ),
          const SizedBox(height: 16),

          // Inventory Report
          _buildReportCard(
            'Inventory Report',
            [
              _buildMetricRow(
                'Total Products',
                _getIntValue(_analytics['inventory'] as Map<String, dynamic>?, 'totalProducts').toString(),
                Icons.inventory,
                Colors.blue,
                isMobile,
              ),
              _buildMetricRow(
                'Low Stock Products',
                _getIntValue(_analytics['inventory'] as Map<String, dynamic>?, 'lowStockProducts').toString(),
                Icons.warning,
                Colors.orange,
                isMobile,
              ),
              _buildMetricRow(
                'Out of Stock',
                _getIntValue(_analytics['inventory'] as Map<String, dynamic>?, 'outOfStock').toString(),
                Icons.remove_circle,
                Colors.red,
                isMobile,
              ),
              _buildMetricRow(
                'Total Inventory Value',
                '\$${_getDoubleValue(_analytics['inventory'] as Map<String, dynamic>?, 'totalValue').toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.green,
                isMobile,
              ),
            ],
            Colors.orange,
            isMobile,
          ),
          const SizedBox(height: 16),

          // Prescription Report
          _buildReportCard(
            'Prescription Report',
            [
              _buildMetricRow(
                'Total Prescriptions',
                _getIntValue(_analytics['prescriptions'] as Map<String, dynamic>?, 'totalPrescriptions').toString(),
                Icons.description,
                Colors.purple,
                isMobile,
              ),
              _buildMetricRow(
                'Pending',
                _getIntValue(_analytics['prescriptions'] as Map<String, dynamic>?, 'pending').toString(),
                Icons.pending,
                Colors.orange,
                isMobile,
              ),
              _buildMetricRow(
                'Approved',
                _getIntValue(_analytics['prescriptions'] as Map<String, dynamic>?, 'approved').toString(),
                Icons.check_circle,
                Colors.green,
                isMobile,
              ),
              _buildMetricRow(
                'Rejected',
                _getIntValue(_analytics['prescriptions'] as Map<String, dynamic>?, 'rejected').toString(),
                Icons.cancel,
                Colors.red,
                isMobile,
              ),
            ],
            Colors.purple,
            isMobile,
          ),
          const SizedBox(height: 16),

          // Support Report
          _buildReportCard(
            'Support Report',
            [
              _buildMetricRow(
                'Total Tickets',
                _getIntValue(_analytics['support'] as Map<String, dynamic>?, 'totalTickets').toString(),
                Icons.support_agent,
                Colors.teal,
                isMobile,
              ),
              _buildMetricRow(
                'Open Tickets',
                _getIntValue(_analytics['support'] as Map<String, dynamic>?, 'openTickets').toString(),
                Icons.inbox,
                Colors.orange,
                isMobile,
              ),
              _buildMetricRow(
                'Resolved Tickets',
                _getIntValue(_analytics['support'] as Map<String, dynamic>?, 'resolvedTickets').toString(),
                Icons.done_all,
                Colors.green,
                isMobile,
              ),
            ],
            Colors.teal,
            isMobile,
          ),

          // Users Report (Admin only)
          if (user?.isAdmin == true) ...[
            const SizedBox(height: 16),
            _buildReportCard(
              'Users Report',
              [
                _buildMetricRow(
                  'Total Users',
                  _getIntValue(_analytics['users'] as Map<String, dynamic>?, 'totalUsers').toString(),
                  Icons.people,
                  Colors.blue,
                  isMobile,
                ),
                _buildMetricRow(
                  'Admins',
                  _getIntValue(_analytics['users'] as Map<String, dynamic>?, 'admins').toString(),
                  Icons.admin_panel_settings,
                  Colors.red,
                  isMobile,
                ),
                _buildMetricRow(
                  'Pharmacists',
                  _getIntValue(_analytics['users'] as Map<String, dynamic>?, 'pharmacists').toString(),
                  Icons.medical_services,
                  Colors.purple,
                  isMobile,
                ),
                _buildMetricRow(
                  'Customers',
                  _getIntValue(_analytics['users'] as Map<String, dynamic>?, 'customers').toString(),
                  Icons.person,
                  Colors.green,
                  isMobile,
                ),
              ],
              Colors.blue,
              isMobile,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildReportCard(String title, List<Widget> metrics, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics, color: color, size: isMobile ? 20 : 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...metrics,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: isMobile ? 18 : 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}