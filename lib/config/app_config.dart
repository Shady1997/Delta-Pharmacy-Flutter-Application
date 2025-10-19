class AppConfig {
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  static const int itemsPerPage = 20;
  static const int lowStockThreshold = 10;

  static const List<String> orderStatuses = [
    'PENDING',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED',
  ];

  static const List<String> prescriptionStatuses = [
    'PENDING',
    'APPROVED',
    'REJECTED',
  ];

  static const List<String> ticketStatuses = [
    'OPEN',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED',
  ];

  static const List<String> productCategories = [
    'Antibiotics',
    'Pain Relief',
    'Vitamins',
    'Cold & Flu',
    'Diabetes Care',
    'Heart Health',
    'Skin Care',
    'Other',
  ];
}