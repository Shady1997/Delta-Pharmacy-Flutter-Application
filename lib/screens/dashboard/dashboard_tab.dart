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

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    if (user.isAdmin) {
      return _buildAdminDashboard();
    } else if (user.isPharmacist) {
      return _buildPharmacistDashboard();
    } else {
      return _buildCustomerDashboard();
    }
  }

  Widget _buildAdminDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Administrator Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete system overview and management',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: 'Total Products',
                  value: _stats['totalProducts'].toString(),
                  icon: Icons.medication,
                  color: Colors.blue,
                  subtitle: 'In inventory',
                ),
                StatCard(
                  title: 'Pending Orders',
                  value: _stats['pendingOrders'].toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  subtitle: 'Needs processing',
                ),
                StatCard(
                  title: 'Pending Prescriptions',
                  value: _stats['pendingPrescriptions'].toString(),
                  icon: Icons.assignment,
                  color: Colors.purple,
                  subtitle: 'Awaiting review',
                ),
                StatCard(
                  title: 'Support Tickets',
                  value: _stats['supportTickets'].toString(),
                  icon: Icons.support_agent,
                  color: Colors.teal,
                  subtitle: 'Open tickets',
                ),
                StatCard(
                  title: 'Total Users',
                  value: _stats['totalUsers'].toString(),
                  icon: Icons.people,
                  color: Colors.green,
                  subtitle: 'Registered users',
                ),
                StatCard(
                  title: 'Low Stock Alert',
                  value: _stats['lowStock'].toString(),
                  icon: Icons.warning,
                  color: Colors.red,
                  subtitle: 'Needs restock',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPharmacistDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pharmacist Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Prescription review and order management',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: 'Pending Prescriptions',
                  value: _stats['pendingPrescriptions'].toString(),
                  icon: Icons.assignment,
                  color: Colors.purple,
                  subtitle: 'Needs your review',
                ),
                StatCard(
                  title: 'Pending Orders',
                  value: _stats['pendingOrders'].toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  subtitle: 'To be processed',
                ),
                StatCard(
                  title: 'Support Tickets',
                  value: _stats['supportTickets'].toString(),
                  icon: Icons.support_agent,
                  color: Colors.teal,
                  subtitle: 'Customer inquiries',
                ),
                StatCard(
                  title: 'Low Stock Alert',
                  value: _stats['lowStock'].toString(),
                  icon: Icons.warning,
                  color: Colors.red,
                  subtitle: 'Check inventory',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Delta Pharmacy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your health, our priority',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'Browse Products',
                value: '150+',
                icon: Icons.medication,
                color: Colors.blue,
                subtitle: 'Available medicines',
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
                onTap: () {
                  // Navigate to support tab
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTip('Upload prescriptions for prescription-required medicines'),
                _buildTip('Track your order status in real-time'),
                _buildTip('Contact support for any assistance'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}