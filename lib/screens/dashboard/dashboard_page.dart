import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../analytics/analytics_tab.dart';
import '../auth/login_page.dart';
import '../orders/orders_tab.dart';
import '../prescriptions/prescriptions_tab.dart';
import '../products/products_tab.dart';
import '../support/support_tab.dart';
import '../users/users_tab.dart';
import 'dashboard_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String _successMessage = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset index if it exceeds available pages
    final user = ApiService.currentUser;
    final pages = _getVisiblePages(user);
    if (_selectedIndex >= pages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedIndex = 0);
        }
      });
    }
  }

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

  void _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  List<Widget> _getVisiblePages(User? user) {
    if (user == null) return [DashboardTab(onMessage: _showMessage)];

    if (user.isAdmin) {
      return [
        DashboardTab(onMessage: _showMessage),
        ProductsTab(onMessage: _showMessage),
        OrdersTab(onMessage: _showMessage),
        PrescriptionsTab(onMessage: _showMessage),
        SupportTab(onMessage: _showMessage),
        AnalyticsTab(onMessage: _showMessage),
        UsersTab(onMessage: _showMessage),
      ];
    } else if (user.isPharmacist) {
      return [
        DashboardTab(onMessage: _showMessage),
        OrdersTab(onMessage: _showMessage),
        PrescriptionsTab(onMessage: _showMessage),
        SupportTab(onMessage: _showMessage),
        AnalyticsTab(onMessage: _showMessage),
      ];
    } else {
      // Customer
      return [
        DashboardTab(onMessage: _showMessage),
        ProductsTab(onMessage: _showMessage),
        OrdersTab(onMessage: _showMessage),
        PrescriptionsTab(onMessage: _showMessage),
        SupportTab(onMessage: _showMessage),
      ];
    }
  }

  List<_TabConfig> _getVisibleTabs(User? user) {
    if (user == null) return [_TabConfig(Icons.dashboard, 'Dashboard')];

    if (user.isAdmin) {
      return [
        _TabConfig(Icons.dashboard, 'Dashboard'),
        _TabConfig(Icons.medication, 'Products'),
        _TabConfig(Icons.shopping_cart, 'Orders'),
        _TabConfig(Icons.assignment, 'Prescriptions'),
        _TabConfig(Icons.support_agent, 'Support'),
        _TabConfig(Icons.analytics, 'Analytics'),
        _TabConfig(Icons.people, 'Users'),
      ];
    } else if (user.isPharmacist) {
      return [
        _TabConfig(Icons.dashboard, 'Dashboard'),
        _TabConfig(Icons.shopping_cart, 'Orders'),
        _TabConfig(Icons.assignment, 'Prescriptions'),
        _TabConfig(Icons.support_agent, 'Support'),
        _TabConfig(Icons.analytics, 'Analytics'),
      ];
    } else {
      return [
        _TabConfig(Icons.dashboard, 'Dashboard'),
        _TabConfig(Icons.medication, 'Products'),
        _TabConfig(Icons.shopping_cart, 'My Orders'),
        _TabConfig(Icons.assignment, 'My Prescriptions'),
        _TabConfig(Icons.support_agent, 'Support'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final pages = _getVisiblePages(user);
    final tabs = _getVisibleTabs(user);

    // Ensure selectedIndex is valid
    if (_selectedIndex >= pages.length && pages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedIndex = 0);
        }
      });
    }

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
                          Row(
                            children: [
                              Text(
                                user?.getRoleDisplayName() ?? 'Dashboard',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (user != null) ...[
                                const SizedBox(width: 8),
                                const Text('•',
                                    style: TextStyle(color: Colors.black54)),
                                const SizedBox(width: 8),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
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
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red.shade700),
                      onPressed: () => setState(() => _errorMessage = ''),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
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
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage,
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green.shade700),
                      onPressed: () => setState(() => _successMessage = ''),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
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
                  children: tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    return _buildTab(index, tab.icon, tab.label);
                  }).toList(),
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
                  ],
                ),
                child: pages.isNotEmpty && _selectedIndex < pages.length
                    ? pages[_selectedIndex]
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No content available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _handleLogout,
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
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
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
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

class _TabConfig {
  final IconData icon;
  final String label;

  _TabConfig(this.icon, this.label);
}