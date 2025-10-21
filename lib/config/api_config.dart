class ApiConfig {
  static const String baseUrl = 'http://192.168.1.104:8545/pharmacy-api/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String profile = '$baseUrl/auth/profile';

  // Products endpoints
  static const String products = '$baseUrl/products';
  static const String lowStockProducts = '$baseUrl/inventory/stock-levels';
  static const String updateStock = '$baseUrl/inventory/update-stock';
  static const String searchProducts = '$baseUrl/search';

  // Orders endpoints
  static const String orders = '$baseUrl/orders';

  // Prescriptions endpoints
  static const String prescriptions = '$baseUrl/prescriptions';
  static const String pendingPrescriptions = '$baseUrl/prescriptions/pending';

  // Support endpoints
  static const String supportTickets = '$baseUrl/support/tickets';
  static const String allTickets = '$baseUrl/support/tickets/all';

  // Analytics endpoints
  static const String salesReport = '$baseUrl/reports/sales';
  static const String inventoryReport = '$baseUrl/reports/inventory';
  static const String usersReport = '$baseUrl/reports/users';

  // Payments endpoints
  static const String payments = '$baseUrl/payments';
  static const String initiatePayment = '$baseUrl/payments/initiate';
  static const String verifyPayment = '$baseUrl/payments/verify';

  // Notifications endpoints
  static const String notifications = '$baseUrl/notifications';

  // Reviews endpoints
  static const String reviews = '$baseUrl/reviews';

  // Chat endpoint
  static const String chat = '$baseUrl/chat';
}