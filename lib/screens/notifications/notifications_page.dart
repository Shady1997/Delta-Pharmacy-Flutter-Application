import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/notification.dart';
import '../../utils/date_formatter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = ApiService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final notifications = _showUnreadOnly
          ? await ApiService.getUnreadNotifications(user.id)
          : await ApiService.getUserNotifications(user.id);
      setState(() => _notifications = notifications);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await ApiService.markNotificationAsRead(notification.id);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER_UPDATE':
        return Colors.orange;
      case 'PAYMENT_UPDATE':
        return Colors.green;
      case 'PRESCRIPTION_UPDATE':
        return Colors.purple;
      case 'SYSTEM':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER_UPDATE':
        return Icons.shopping_cart;
      case 'PAYMENT_UPDATE':
        return Icons.payment;
      case 'PRESCRIPTION_UPDATE':
        return Icons.medical_services;
      case 'SYSTEM':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Toggle
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showUnreadOnly ? 'Unread Notifications' : 'All Notifications',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Text('Unread Only'),
                    Switch(
                      value: _showUnreadOnly,
                      onChanged: (value) {
                        setState(() => _showUnreadOnly = value);
                        _loadNotifications();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _showUnreadOnly
                        ? 'No unread notifications'
                        : 'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                padding: EdgeInsets.all(isMobile ? 8 : 16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: notification.isRead
                        ? Colors.white
                        : Colors.blue.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        _getTypeColor(notification.type)
                            .withOpacity(0.2),
                        child: Icon(
                          _getTypeIcon(notification.type),
                          color: _getTypeColor(notification.type),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatDate(
                                notification.createdAt),
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: !notification.isRead
                          ? IconButton(
                        icon: const Icon(Icons.check,
                            color: Colors.green),
                        onPressed: () =>
                            _markAsRead(notification),
                        tooltip: 'Mark as read',
                      )
                          : null,
                      onTap: () => _markAsRead(notification),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}