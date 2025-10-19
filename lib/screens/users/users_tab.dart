import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class UsersTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const UsersTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _filterRole = 'All';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      // If API fails, use mock data as fallback
      setState(() {
        _users = [
          User(
            id: 1,
            username: 'admin',
            email: 'admin@pharmacy.com',
            fullName: 'Admin User',
            phoneNumber: '+1234567890',
            role: 'ADMIN',
          ),
          User(
            id: 2,
            username: 'pharmacist',
            email: 'pharmacist@pharmacy.com',
            fullName: 'Pharmacist User',
            phoneNumber: '+1234567891',
            role: 'PHARMACIST',
          ),
          User(
            id: 3,
            username: 'customer',
            email: 'customer@example.com',
            fullName: 'Customer User',
            phoneNumber: '+1234567892',
            role: 'CUSTOMER',
          ),
        ];
        _filteredUsers = _users;
      });
      widget.onMessage('Using mock data - API not available', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = user.email
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()) ||
            user.fullName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
        final matchesRole = _filterRole == 'All' || user.role == _filterRole;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'PHARMACIST':
        return Colors.purple;
      case 'CUSTOMER':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ApiService.currentUser;

    if (currentUser?.isAdmin != true) {
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
              'User management is only available for Administrators',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Manage user accounts and roles',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  _users.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Admins',
                  _users.where((u) => u.role == 'ADMIN').length.toString(),
                  Icons.admin_panel_settings,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pharmacists',
                  _users.where((u) => u.role == 'PHARMACIST').length.toString(),
                  Icons.medical_services,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Customers',
                  _users.where((u) => u.role == 'CUSTOMER').length.toString(),
                  Icons.person,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filter
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by email or name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterRole,
                  decoration: InputDecoration(
                    labelText: 'Filter by Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: ['All', 'ADMIN', 'PHARMACIST', 'CUSTOMER']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _filterRole = value!);
                    _filterUsers();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

// Add User Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showCreateUserDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create New User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),

          // Users Table
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
                  'Users (${_filteredUsers.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _filteredUsers.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No users found'),
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blue.shade100,
                    ),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _filteredUsers.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user.id.toString())),
                          DataCell(Text(user.fullName)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.phoneNumber)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user.role)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.getRoleDisplayName(),
                                style: TextStyle(
                                  color: _getRoleColor(user.role),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue, size: 20),
                                  onPressed: () {
                                    _showEditUserDialog(user);
                                  },
                                  tooltip: 'Edit User',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: user.id != currentUser?.id
                                      ? () {
                                    _showDeleteConfirmation(user);
                                  }
                                      : null,
                                  tooltip: 'Delete User',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(User user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User: ${user.fullName}'),
              Text('Email: ${user.email}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['ADMIN', 'PHARMACIST', 'CUSTOMER']
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getRoleColor(role),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(role),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedRole = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.updateUserRole(user.id, selectedRole);
                  Navigator.pop(context);
                  widget.onMessage('User role updated successfully', false);
                  _loadUsers();
                } catch (e) {
                  widget.onMessage('Failed to update role: ${e.toString()}', true);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete user "${user.fullName}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement user deletion API call
              widget.onMessage('User deletion functionality coming soon', false);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String selectedRole = 'CUSTOMER';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New User'),
          content: SingleChildScrollView(
            child: Container(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'user@example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Min 8 characters',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '1234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: '123 Main St',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: ['CUSTOMER', 'PHARMACIST', 'ADMIN']
                        .map((role) => DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getRoleColor(role),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(role),
                        ],
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedRole = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    fullNameController.text.isEmpty) {
                  widget.onMessage('Please fill all required fields', true);
                  return;
                }

                try {
                  await ApiService.createUser({
                    'email': emailController.text,
                    'password': passwordController.text,
                    'fullName': fullNameController.text,
                    'phone': phoneController.text,
                    'address': addressController.text,
                    'role': selectedRole,
                  });

                  Navigator.pop(context);
                  widget.onMessage('User created successfully', false);
                  _loadUsers();
                } catch (e) {
                  widget.onMessage('Failed to create user: ${e.toString()}', true);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}