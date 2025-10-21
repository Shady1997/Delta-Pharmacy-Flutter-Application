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
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Mock data - replace with actual API calls
      setState(() {
        _stats = {
          'totalProducts': 150,
          'pendingOrders': 12,
          'pendingPrescriptions': 8,
          'supportTickets': 5,
          'totalUsers': 500,
          'lowStock': 15,
        };
      });
    } catch (e) {
      widget.onMessage('Failed to load dashboard: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
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
                value: _stats['totalProducts'].toString(),
                icon: Icons.medication,
                color: Colors.blue,
                subtitle: 'In inventory',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Pending Orders',
                value: _stats['pendingOrders'].toString(),
                icon: Icons.shopping_cart,
                color: Colors.orange,
                subtitle: 'Needs processing',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Pending Prescriptions',
                value: _stats['pendingPrescriptions'].toString(),
                icon: Icons.assignment,
                color: Colors.purple,
                subtitle: 'Awaiting review',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Support Tickets',
                value: _stats['supportTickets'].toString(),
                icon: Icons.support_agent,
                color: Colors.teal,
                subtitle: 'Open tickets',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Total Users',
                value: _stats['totalUsers'].toString(),
                icon: Icons.people,
                color: Colors.green,
                subtitle: 'Registered users',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Low Stock Alert',
                value: _stats['lowStock'].toString(),
                icon: Icons.warning,
                color: Colors.red,
                subtitle: 'Needs restock',
                isCompact: isMobile,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPharmacistDashboard(bool isMobile) {
    return ListView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
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
                value: _stats['pendingPrescriptions'].toString(),
                icon: Icons.assignment,
                color: Colors.purple,
                subtitle: 'Needs your review',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Pending Orders',
                value: _stats['pendingOrders'].toString(),
                icon: Icons.shopping_cart,
                color: Colors.orange,
                subtitle: 'To be processed',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Support Tickets',
                value: _stats['supportTickets'].toString(),
                icon: Icons.support_agent,
                color: Colors.teal,
                subtitle: 'Customer inquiries',
                isCompact: isMobile,
              ),
              StatCard(
                title: 'Low Stock Alert',
                value: _stats['lowStock'].toString(),
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
        const SizedBox(height: 16),
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
              value: '150+',
              icon: Icons.medication,
              color: Colors.blue,
              subtitle: 'Available medicines',
              isCompact: isMobile,
              onTap: () {
                // Navigate to products tab
              },
            ),
            StatCard(
              title: 'My Orders',
              value: '3',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              subtitle: 'Active orders',
              isCompact: isMobile,
              onTap: () {
                // Navigate to orders tab
              },
            ),
            StatCard(
              title: 'My Prescriptions',
              value: '2',
              icon: Icons.assignment,
              color: Colors.purple,
              subtitle: 'Uploaded prescriptions',
              isCompact: isMobile,
              onTap: () {
                // Navigate to prescriptions tab
              },
            ),
            StatCard(
              title: 'Support',
              value: '24/7',
              icon: Icons.support_agent,
              color: Colors.teal,
              subtitle: 'We are here to help',
              isCompact: isMobile,
              onTap: () {
                // Navigate to support tab
              },
            ),
          ],
        ),
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
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
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
}