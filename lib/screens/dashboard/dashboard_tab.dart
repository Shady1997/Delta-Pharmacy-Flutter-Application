import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../widgets/stat_card.dart';

class DashboardTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const DashboardTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await ApiService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      print('Dashboard error: $e');  // Add this to see the error
      // Don't show error to user, just use fallback data
      if (mounted) {
        setState(() {
          _stats = _getFallbackStats();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _getFallbackStats() {
    final user = ApiService.currentUser;
    if (user?.isAdmin == true) {
      return {
        'totalProducts': 0,
        'pendingOrders': 0,
        'pendingPrescriptions': 0,
        'supportTickets': 0,
        'totalUsers': 0,
        'lowStock': 0,
      };
    } else if (user?.isPharmacist == true) {
      return {
        'pendingPrescriptions': 0,
        'pendingOrders': 0,
        'supportTickets': 0,
        'lowStock': 0,
        'totalProducts': 0,
      };
    } else {
      return {
        'myOrders': 0,
        'pendingOrders': 0,
        'myPrescriptions': 0,
        'pendingPrescriptions': 0,
        'totalProducts': 0,
        'myTickets': 0,
      };
    }
  }

  int _getStatValue(String key) {
    final value = _stats[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    if (user.isAdmin) {
      return _buildAdminDashboard(isMobile);
    } else if (user.isPharmacist) {
      return _buildPharmacistDashboard(isMobile);
    } else {
      return _buildCustomerDashboard(isMobile);
    }
  }

  Widget _buildAdminDashboard(bool isMobile) {
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
                  'Administrator Dashboard',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete system overview and management',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 3,
            crossAxisSpacing: isMobile ? 8 : 16,
            mainAxisSpacing: isMobile ? 8 : 16,
            childAspectRatio: isMobile ? 1.2 : 1.5,
            children: [
              StatCard(
                title: 'Total Products',
                value: _getStatValue('totalProducts').toString(),
                icon: Icons.medication,
                color: Colors.blue,
                subtitle: 'In inventory',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Pending Orders',
                value: _getStatValue('pendingOrders').toString(),
                icon: Icons.shopping_cart,
                color: Colors.orange,
                subtitle: 'Needs processing',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Pending Prescriptions',
                value: _getStatValue('pendingPrescriptions').toString(),
                icon: Icons.assignment,
                color: Colors.purple,
                subtitle: 'Awaiting review',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Support Tickets',
                value: _getStatValue('supportTickets').toString(),
                icon: Icons.support_agent,
                color: Colors.teal,
                subtitle: 'Open tickets',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Total Users',
                value: _getStatValue('totalUsers').toString(),
                icon: Icons.people,
                color: Colors.green,
                subtitle: 'Registered users',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Low Stock Alert',
                value: _getStatValue('lowStock').toString(),
                icon: Icons.warning,
                color: Colors.red,
                subtitle: 'Needs restock',
                isCompact: isMobile,
              ),
            ],
          ),
        if (_stats.containsKey('totalRevenue')) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Overview',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRevenueStat(
                        'Total Revenue',
                        '\$${(_stats['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                        isMobile,
                      ),
                      _buildRevenueStat(
                        'Total Orders',
                        _getStatValue('totalOrders').toString(),
                        Icons.shopping_bag,
                        Colors.blue,
                        isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPharmacistDashboard(bool isMobile) {
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
                  'Pharmacist Dashboard',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Prescription review and order management',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 2,
            crossAxisSpacing: isMobile ? 8 : 16,
            mainAxisSpacing: isMobile ? 8 : 16,
            childAspectRatio: isMobile ? 1.2 : 1.5,
            children: [
              StatCard(
                title: 'Pending Prescriptions',
                value: _getStatValue('pendingPrescriptions').toString(),
                icon: Icons.assignment,
                color: Colors.purple,
                subtitle: 'Needs your review',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Pending Orders',
                value: _getStatValue('pendingOrders').toString(),
                icon: Icons.shopping_cart,
                color: Colors.orange,
                subtitle: 'To be processed',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Support Tickets',
                value: _getStatValue('supportTickets').toString(),
                icon: Icons.support_agent,
                color: Colors.teal,
                subtitle: 'Customer inquiries',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Low Stock Alert',
                value: _getStatValue('lowStock').toString(),
                icon: Icons.warning,
                color: Colors.red,
                subtitle: 'Check inventory',
                isCompact: isMobile,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCustomerDashboard(bool isMobile) {
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
                  'Welcome to Delta Pharmacy',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your health, our priority',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 2,
            crossAxisSpacing: isMobile ? 8 : 16,
            mainAxisSpacing: isMobile ? 8 : 16,
            childAspectRatio: isMobile ? 1.2 : 1.5,
            children: [
              StatCard(
                title: 'Browse Products',
                value: _getStatValue('totalProducts').toString(),
                icon: Icons.medication,
                color: Colors.blue,
                subtitle: 'Available medicines',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'My Orders',
                value: _getStatValue('myOrders').toString(),
                icon: Icons.shopping_cart,
                color: Colors.orange,
                subtitle: 'Total orders',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'My Prescriptions',
                value: _getStatValue('myPrescriptions').toString(),
                icon: Icons.assignment,
                color: Colors.purple,
                subtitle: 'Uploaded prescriptions',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Support Tickets',
                value: _getStatValue('myTickets').toString(),
                icon: Icons.support_agent,
                color: Colors.teal,
                subtitle: 'My tickets',
                isCompact: isMobile,
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (_stats.containsKey('pendingOrders') && _getStatValue('pendingOrders') > 0) ...[
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have ${_getStatValue('pendingOrders')} pending order(s)',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Tips',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTip('Upload prescriptions for prescription-required medicines', isMobile),
              _buildTip('Track your order status in real-time', isMobile),
              _buildTip('Contact support for any assistance', isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: isMobile ? 14 : 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueStat(String title, String value, IconData icon, Color color, bool isMobile) {
    return Column(
      children: [
        Icon(icon, size: isMobile ? 32 : 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}