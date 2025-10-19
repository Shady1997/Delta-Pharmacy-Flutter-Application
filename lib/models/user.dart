class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? address;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? json['email']?.split('@')[0] ?? '',
      email: json['email'],
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'address': address,
    };
  }

  // Role checker methods
  bool get isAdmin => role == 'ADMIN';
  bool get isPharmacist => role == 'PHARMACIST';
  bool get isCustomer => role == 'CUSTOMER';

  // Permission methods
  bool canManageProducts() => isAdmin;
  bool canManageUsers() => isAdmin;
  bool canApprovePrescriptions() => isAdmin || isPharmacist;
  bool canViewAllOrders() => isAdmin || isPharmacist;
  bool canViewAnalytics() => isAdmin || isPharmacist;
  bool canUpdateOrderStatus() => isAdmin || isPharmacist;
  bool canRespondToTickets() => isAdmin || isPharmacist;
  bool canManageInventory() => isAdmin;

  String getRoleDisplayName() {
    switch (role) {
      case 'ADMIN':
        return 'Administrator';
      case 'PHARMACIST':
        return 'Pharmacist';
      case 'CUSTOMER':
        return 'Customer';
      default:
        return role;
    }
  }
}