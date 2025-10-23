import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../analytics/analytics_tab.dart';
import '../auth/login_page.dart';
import '../notifications/notifications_page.dart';
import '../orders/orders_tab.dart';
import '../prescriptions/prescriptions_tab.dart';
import '../products/products_tab.dart';
import '../support/support_tab.dart';
import '../chat/chat_page.dart';
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

  String _message = '';
  bool _isError = false;
  Timer? _notificationTimer;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _startNotificationPolling();
    _selectedIndex = 0;
  }
  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }
  void _startNotificationPolling() {
    _loadUnreadCount(); // Load immediately

    // Poll every 30 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUnreadCount();
    });
  }

  // ⬇️⬇️⬇️ REPLACE THIS METHOD ⬇️⬇️⬇️
  Future<void> _loadUnreadCount() async {
    final user = ApiService.currentUser;
    if (user == null) return;

    try {
      final notifications = await ApiService.getUnreadNotifications(user.id);
      final newCount = notifications.length;

      if (mounted) {
        // Show toast if new notifications arrived
        if (newCount > _unreadCount && _unreadCount > 0) {
          final newNotifications = newCount - _unreadCount;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have $newNotifications new notification${newNotifications > 1 ? 's' : ''}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue.shade600,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  ).then((_) => _loadUnreadCount());
                },
              ),
            ),
          );
        }

        setState(() {
          _unreadCount = newCount;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    if (_selectedIndex >= pages.length && pages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedIndex = 0);
        }
      });
    }

    // Use bottom navigation for mobile, top tabs for desktop
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_pharmacy, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delta Pharmacy',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.getRoleDisplayName() ?? 'Dashboard',
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          actions: [
            // Chat Button
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
              tooltip: 'Chat with Support',
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages
            if (_errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border(
                    left: BorderSide(color: Colors.red.shade500, width: 4),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red.shade700, size: 18),
                      onPressed: () => setState(() => _errorMessage = ''),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            if (_successMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border(
                    left: BorderSide(color: Colors.green.shade500, width: 4),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage,
                        style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.green.shade700, size: 18),
                      onPressed: () => setState(() => _successMessage = ''),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            // Content
            Expanded(
              child: pages.isNotEmpty && _selectedIndex < pages.length
                  ? pages[_selectedIndex]
                  : _buildNoContentView(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue.shade600,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: tabs.map((tab) {
            String label = tab.label;
            if (label.length > 12) {
              label = label.substring(0, 10) + '..';
            }
            return BottomNavigationBarItem(
              icon: Icon(tab.icon, size: 22),
              label: label,
            );
          }).toList(),
        ),
      );
    }

    // Desktop/Tablet layout with top tabs
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
              margin: EdgeInsets.all(isTablet ? 12 : 16),
              padding: EdgeInsets.all(isTablet ? 16 : 24),
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
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_pharmacy,
                            color: Colors.blue.shade700,
                            size: isTablet ? 24 : 32,
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Delta Pharmacy',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user?.getRoleDisplayName() ?? 'Dashboard',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (user != null && !isTablet) ...[
                                    const SizedBox(width: 8),
                                    const Text('•',
                                        style: TextStyle(color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        user.email,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 16,
                        vertical: isTablet ? 10 : 12,
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
                    return _buildTab(index, tab.icon, tab.label, isTablet);
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
                    : _buildNoContentView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label, bool isTablet) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 16,
          vertical: isTablet ? 12 : 16,
        ),
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
              size: isTablet ? 18 : 20,
              color: isSelected ? Colors.blue.shade600 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 13 : 14,
                color: isSelected ? Colors.blue.shade600 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoContentView() {
    return Center(
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
    );
  }
}

class _TabConfig {
  final IconData icon;
  final String label;

  _TabConfig(this.icon, this.label);
}
