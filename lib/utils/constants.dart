import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Delta Pharmacy';
  static const String apiBaseUrl = 'http://localhost:8545/pharmacy-api/api';

  // Demo Credentials - Updated to match README
  static const String demoAdminEmail = 'admin@pharmacy.com';
  static const String demoAdminPassword = 'admin123';

  static const String demoPharmacistEmail = 'pharmacist@pharmacy.com';
  static const String demoPharmacistPassword = 'pharma123';

  static const String demoCustomerEmail = 'customer@example.com';
  static const String demoCustomerPassword = 'customer123';
}

class UserRoles {
  static const String admin = 'ADMIN';
  static const String pharmacist = 'PHARMACIST';
  static const String customer = 'CUSTOMER';
}

class AppColors {
  static const primaryColor = Color(0xFF2196F3);
  static const secondaryColor = Color(0xFF3F51B5);
  static const accentColor = Color(0xFF00BCD4);

  static const successColor = Color(0xFF4CAF50);
  static const warningColor = Color(0xFFFF9800);
  static const errorColor = Color(0xFFF44336);
  static const infoColor = Color(0xFF2196F3);

  static const backgroundColor = Color(0xFFF5F5F5);
  static const cardColor = Color(0xFFFFFFFF);
  static const textPrimaryColor = Color(0xFF212121);
  static const textSecondaryColor = Color(0xFF757575);

  // Role colors
  static const adminColor = Color(0xFFE91E63);
  static const pharmacistColor = Color(0xFF9C27B0);
  static const customerColor = Color(0xFF2196F3);
}

class AppStrings {
  static const loginTitle = 'Delta Pharmacy';
  static const loginSubtitle = 'Admin Dashboard';
  static const emailHint = 'Enter your email';
  static const passwordHint = 'Enter your password';
  static const signInButton = 'Sign In';
  static const demoCredentials = 'Demo Credentials:';
}