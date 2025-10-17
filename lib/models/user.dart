class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
    );
  }
}
