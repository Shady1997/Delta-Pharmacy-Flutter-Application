import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String _successMessage = '';
  String _errorMessage = '';

  void _showMessage(String message, bool isError) {
    setState(() {
      if (isError) {
        _errorMessage = message;
        _successMessage = '';
      } else {
        _successMessage = message;
        _errorMessage = '';
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
          _successMessage = '';
        });
      }
    });
  }

  void _handleLogout() {
    ApiService.authToken = null;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(onMessage: _showMessage),
      ProductsTab(onMessage: _showMessage),
      OrdersTab(onMessage: _showMessage),
      PrescriptionsTab(onMessage: _showMessage),
      SupportTab(onMessage: _showMessage),
      AnalyticsTab(onMessage: _showMessage),
    ];

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.indigo.shade50,
              ],
            ),
          ),
          child: Column(
              children: [
          // Header
          Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_pharmacy,
                      color: Colors.blue.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delta Pharmacy',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Messages
        if (_errorMessage.isNotEmpty)
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(
          left: BorderSide(color: Colors.red.shade500, width: 4),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red.shade700),
      ),
    ),
    if (_successMessage.isNotEmpty)
    Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.green.shade50,
    border: Border(
    left: BorderSide(color: Colors.green.shade500, width: 4),
    ),
    borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
    _successMessage,
    style: TextStyle(color: Colors.green.shade700),
    ),
    ),

    // Tabs
    Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
    children: [
    _buildTab(0, Icons.dashboard, 'Dashboard'),
    _buildTab(1, Icons.medication, 'Products'),
    _buildTab(2, Icons.shopping_cart, 'Orders'),
    _buildTab(3, Icons.assignment, 'Prescriptions'),
    _buildTab(4, Icons.support_agent, 'Support'),
    _buildTab(5, Icons.analytics, 'Analytics'),
    ],
    ),
    ),
    ),

    // Content
    Expanded(
    child: Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(12),
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ),
    ),
    child: pages[_selectedIndex],
    ),
    ),
    ],
    ),
    ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue.shade600 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.blue.shade600 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue.shade600 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}