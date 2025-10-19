import 'package:flutter/material.dart';
import 'package:mobile_banking_flutter/screens/analytics/report_card.dart';
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
  Map<String, dynamic> _salesReport = {};
  Map<String, dynamic> _inventoryReport = {};
  Map<String, dynamic> _usersReport = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final user = ApiService.currentUser;

    if (user?.canViewAnalytics() != true) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sales = await ApiService.getSalesReport();
      final inventory = await ApiService.getInventoryReport();

      setState(() {
        _salesReport = sales;
        _inventoryReport = inventory;
      });

      if (user?.isAdmin == true) {
        final users = await ApiService.getUsersReport();
        setState(() => _usersReport = users);
      }
    } catch (e) {
      widget.onMessage('Failed to load reports: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

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
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
          'Analytics & Reports',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Business insights and performance metrics',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),

        if (_isLoading)
    const Center(child: CircularProgressIndicator())
    else ...[
    // Sales Report
    ReportCard(
    title: 'Sales Report',
    data: _salesReport,
    icon: Icons.attach_money,
    color: Colors.green,
    ),
    const SizedBox(height: 16),

          // Inventory Report
          ReportCard(
            title: 'Inventory Report',
            data: _inventoryReport,
            icon: Icons.inventory,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),

          // Users Report (Admin only)
          if (user?.isAdmin == true) ...[
            ReportCard(
              title: 'Users Report',
              data: _usersReport,
              icon: Icons.people,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
          ],

          // Refresh Button
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Reports'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
          ],
        ),
    );
  }
}