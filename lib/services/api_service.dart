import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/prescription.dart';
import '../models/support_ticket.dart';
import 'auth_service.dart';
import '../models/payment.dart';
import '../models/notification.dart';
import '../models/review.dart';
import '../models/chat_message.dart';



class ApiService {
  static const String baseUrl = 'http://localhost:8545/pharmacy-api/api';

  static String? get authToken => AuthService.authToken;

  static User? get currentUser => AuthService.currentUser;


  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await AuthService.login(email, password);
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> products = data['data'] ?? data;
      return products.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  static Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: getHeaders(),
      body: json.encode(productData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Product.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  static Future<List<Product>> getLowStockProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory/stock-levels'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> products = data['data'] ?? data;
      return products.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load low stock products');
  }

  // Orders
  static Future<List<Order>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> orders = data['data'] ?? data;
      return orders.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to load orders');
  }

  static Future<List<Order>> getUserOrders(int userId) async {
    try {
      // Use the "get all orders" endpoint and filter on client side
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: getHeaders(),
      );

      print('Get Orders Status: ${response.statusCode}');
      print('Get Orders Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> allOrders = data['data'] ?? [];
          // Filter by userId on client side
          return allOrders
              .map((json) => Order.fromJson(json))
              .where((order) => order.userId == userId)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get User Orders Error: $e');
      return [];
    }
  }

  static Future<Order> updateOrderStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: getHeaders(),
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Order.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  // Prescriptions
  static Future<List<Prescription>> getPendingPrescriptions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/prescriptions/pending'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> prescriptions = data['data'] ?? data;
      return prescriptions.map((json) => Prescription.fromJson(json)).toList();
    }
    throw Exception('Failed to load prescriptions');
  }

  static Future<List<Prescription>> getUserPrescriptions(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prescriptions/user/$userId'), // ← Changed endpoint
        headers: getHeaders(),
      );

      print('Get User Prescriptions Status: ${response.statusCode}');
      print('Get User Prescriptions Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> prescriptions = data['data'] ?? [];
          return prescriptions
              .map((json) => Prescription.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get User Prescriptions Error: $e');
      return [];
    }
  }

  static Future<void> rejectPrescription(int id, String reason) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/prescriptions/$id/reject'),
        headers: getHeaders(),
        body: json.encode({'reason': reason}),
      );

      print('Reject Prescription Status: ${response.statusCode}');
      print('Reject Prescription Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't try to parse the response as Prescription object
          return; // Just return void on success
        }
      }
      throw Exception('Failed to reject prescription');
    } catch (e) {
      print('Reject Prescription Error: $e');
      rethrow;
    }
  }

  static Future<void> approvePrescription(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/prescriptions/$id/approve'),
        headers: getHeaders(),
      );

      print('Approve Prescription Status: ${response.statusCode}');
      print('Approve Prescription Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't try to parse the response as Prescription object
          return; // Just return void on success
        }
      }
      throw Exception('Failed to approve prescription');
    } catch (e) {
      print('Approve Prescription Error: $e');
      rethrow;
    }
  }

  // Support Tickets
  static Future<List<SupportTicket>> getAllTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/tickets/all'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tickets = data['data'] ?? data;
      return tickets.map((json) => SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<SupportTicket>> getUserTickets(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/tickets?userId=$userId'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tickets = data['data'] ?? data;
      return tickets.map((json) => SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load user tickets');
  }

  static Future<SupportTicket> updateTicketStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/support/ticket/$id/status'),
      headers: getHeaders(),
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SupportTicket.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  // Analytics
  static Future<Map<String, dynamic>> getSalesReport() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/sales'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    }
    throw Exception('Failed to load sales report');
  }

  static Future<Map<String, dynamic>> getInventoryReport() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/inventory'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    }
    throw Exception('Failed to load inventory report');
  }

  static Future<Map<String, dynamic>> getUsersReport() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/users'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    }
    throw Exception('Failed to load users report');
  }

  // Users (Admin only)
  static Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> users = data['data'] ?? [];
        return users.map((json) => User.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load users');
  }

  // Orders
  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: getHeaders(),
        body: json.encode(orderData),
      );

      print('Order Response Status: ${response.statusCode}');
      print('Order Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Check if response has success field
        if (data['success'] == true) {
          return Order.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create order');
        }
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      print('Create Order Error: $e');
      rethrow;
    }
  }

  // Users (Admin only)
  static Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: json.encode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create user');
  }

  static Future<User> updateUserRole(int userId, String role) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: getHeaders(),
      body: json.encode({'role': role}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
    }
    throw Exception('Failed to update user role');
  }

  static Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // Support Tickets
  static Future<SupportTicket> createSupportTicket(
      Map<String, dynamic> ticketData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/ticket'),
        headers: getHeaders(),
        body: json.encode(ticketData),
      );

      print('Create Ticket Status: ${response.statusCode}');
      print('Create Ticket Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SupportTicket.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create support ticket');
    } catch (e) {
      print('Create Ticket Error: $e');
      rethrow;
    }
  }

  // Prescriptions
  static Future<Prescription> uploadPrescription(
      Map<String, dynamic> prescriptionData) async {
    try {
      // Build query parameters
      final queryParams = {
        'userId': prescriptionData['userId'].toString(),
        'fileName': prescriptionData['fileName'],
        'fileType': prescriptionData['fileType'],
        'doctorName': prescriptionData['doctorName'],
        if (prescriptionData['notes'] != null)
          'notes': prescriptionData['notes'],
      };

      final uri = Uri.parse('$baseUrl/prescriptions/upload')
          .replace(queryParameters: queryParams);

      print('Upload Prescription URL: $uri');

      final response = await http.post(
        uri,
        headers: getHeaders(),
      );

      print('Upload Prescription Status: ${response.statusCode}');
      print('Upload Prescription Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Prescription.fromJson(data['data']);
        }
      }
      throw Exception('Failed to upload prescription');
    } catch (e) {
      print('Upload Prescription Error: $e');
      rethrow;
    }
  }

  static Future<List<Prescription>> getAllPrescriptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prescriptions'),
        headers: getHeaders(),
      );

      print('Get All Prescriptions Status: ${response.statusCode}');
      print('Get All Prescriptions Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> prescriptions = data['data'] ?? [];
          return prescriptions
              .map((json) => Prescription.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get All Prescriptions Error: $e');
      return [];
    }
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('Calling dashboard stats API...');
      print('URL: $baseUrl/dashboard/stats');
      print('Token: $authToken');

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: getHeaders(),
      );

      print('Dashboard Stats Status: ${response.statusCode}');
      print('Dashboard Stats Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    } catch (e) {
      print('Dashboard Stats Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/analytics'),
      headers: getHeaders(),
    );

    print('Analytics Status: ${response.statusCode}');
    print('Analytics Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      }
    }
    throw Exception('Failed to load analytics');
  }

  // Payments
  static Future<Payment> initiatePayment(
      Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/initiate'),
      headers: getHeaders(),
      body: json.encode(paymentData),
    );

    print('Initiate Payment Status: ${response.statusCode}');
    print('Initiate Payment Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Payment.fromJson(data['data']);
      }
    }
    throw Exception('Failed to initiate payment');
  }

  static Future<Payment> verifyPayment(int paymentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/verify'),
      headers: getHeaders(),
      body: json.encode({'paymentId': paymentId}),
    );

    print('Verify Payment Status: ${response.statusCode}');
    print('Verify Payment Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Payment.fromJson(data['data']);
      }
    }
    throw Exception('Failed to verify payment');
  }

  static Future<List<Payment>> getPaymentHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/history?userId=$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> payments = data['data'] ?? [];
        return payments.map((json) => Payment.fromJson(json)).toList();
      }
    }
    return [];
  }

// Notifications
  static Future<List<NotificationModel>> getUserNotifications(
      int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> notifications = data['data'] ?? [];
        return notifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  static Future<List<NotificationModel>> getUnreadNotifications(
      int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$userId/unread'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> notifications = data['data'] ?? [];
        return notifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: getHeaders(),
    );
  }

// Reviews
  static Future<void> createReview(Map<String, dynamic> reviewData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: getHeaders(),
      body: json.encode(reviewData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit review');
    }
  }

  static Future<Map<String, dynamic>> getProductReviews(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/$productId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      }
    }
    return {
      'reviews': [],
      'averageRating': 0.0,
      'totalReviews': 0,
    };
  }

// Chat
static Future<User> getPharmacistForChat() async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/pharmacist'),
    headers: getHeaders(),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return User.fromJson(data['data']);
    }
  }
  throw Exception('No pharmacist available');
}

static Future<List<ChatMessage>> getConversation(int otherUserId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/conversation/$otherUserId'),
    headers: getHeaders(),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true) {
      List<dynamic> messages = data['data'] ?? [];
      return messages.map((json) => ChatMessage.fromJson(json)).toList();
    }
  }
  return [];
}

static Future<ChatMessage> sendChatMessage(int receiverId, String message) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat/send'),
    headers: getHeaders(),
    body: json.encode({
      'receiverId': receiverId,
      'message': message,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true) {
      return ChatMessage.fromJson(data['data']);
    }
  }
  throw Exception('Failed to send message');
}

static Future<List<User>> getChatConversations() async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: getHeaders(),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true) {
      List<dynamic> users = data['data'] ?? [];
      return users.map((json) => User.fromJson(json)).toList();
    }
  }
  return [];
}
}
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/prescription.dart';
import '../models/support_ticket.dart';
import 'auth_service.dart';
import '../models/payment.dart';
import '../models/notification.dart';
import '../models/review.dart';
import '../models/chat_message.dart';

import 'dart:io';
import 'package:http/io_client.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8545/pharmacy-api/api';

  static String? get authToken => AuthService.authToken;

  static User? get currentUser => AuthService.currentUser;

  // Create a single IOClient with proxy set up
  static final IOClient ioClient = IOClient(
    HttpClient()
      ..findProxy = (uri) {
        return "PROXY 192.168.1.4:8888;";
      }
      ..badCertificateCallback =
          (cert, host, port) => true, // optional: accept bad certs
  );

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await AuthService.login(email, password);
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/products'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> products = data['data'] ?? data;
      return products.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  static Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await ioClient.post(
      Uri.parse('$baseUrl/products'),
      headers: getHeaders(),
      body: json.encode(productData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Product.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  static Future<void> deleteProduct(int id) async {
    final response = await ioClient.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  static Future<List<Product>> getLowStockProducts() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/inventory/stock-levels'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> products = data['data'] ?? data;
      return products.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load low stock products');
  }

  // Orders
  static Future<List<Order>> getOrders() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/orders'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> orders = data['data'] ?? data;
      return orders.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to load orders');
  }

  static Future<List<Order>> getUserOrders(int userId) async {
    try {
      // Use the "get all orders" endpoint and filter on client side
      final response = await ioClient.get(
        Uri.parse('$baseUrl/orders'),
        headers: getHeaders(),
      );

      print('Get Orders Status: ${response.statusCode}');
      print('Get Orders Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> allOrders = data['data'] ?? [];
          // Filter by userId on client side
          return allOrders
              .map((json) => Order.fromJson(json))
              .where((order) => order.userId == userId)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get User Orders Error: $e');
      return [];
    }
  }

  static Future<Order> updateOrderStatus(int id, String status) async {
    final response = await ioClient.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: getHeaders(),
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Order.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  // Prescriptions
  static Future<List<Prescription>> getPendingPrescriptions() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/prescriptions/pending'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> prescriptions = data['data'] ?? data;
      return prescriptions.map((json) => Prescription.fromJson(json)).toList();
    }
    throw Exception('Failed to load prescriptions');
  }

  static Future<List<Prescription>> getUserPrescriptions(int userId) async {
    try {
      final response = await ioClient.get(
        Uri.parse('$baseUrl/prescriptions/user/$userId'), // ← Changed endpoint
        headers: getHeaders(),
      );

      print('Get User Prescriptions Status: ${response.statusCode}');
      print('Get User Prescriptions Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> prescriptions = data['data'] ?? [];
          return prescriptions
              .map((json) => Prescription.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get User Prescriptions Error: $e');
      return [];
    }
  }

  static Future<void> rejectPrescription(int id, String reason) async {
    try {
      final response = await ioClient.put(
        Uri.parse('$baseUrl/prescriptions/$id/reject'),
        headers: getHeaders(),
        body: json.encode({'reason': reason}),
      );

      print('Reject Prescription Status: ${response.statusCode}');
      print('Reject Prescription Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't try to parse the response as Prescription object
          return; // Just return void on success
        }
      }
      throw Exception('Failed to reject prescription');
    } catch (e) {
      print('Reject Prescription Error: $e');
      rethrow;
    }
  }

  static Future<void> approvePrescription(int id) async {
    try {
      final response = await ioClient.put(
        Uri.parse('$baseUrl/prescriptions/$id/approve'),
        headers: getHeaders(),
      );

      print('Approve Prescription Status: ${response.statusCode}');
      print('Approve Prescription Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't try to parse the response as Prescription object
          return; // Just return void on success
        }
      }
      throw Exception('Failed to approve prescription');
    } catch (e) {
      print('Approve Prescription Error: $e');
      rethrow;
    }
  }

  // Support Tickets
  static Future<List<SupportTicket>> getAllTickets() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/support/tickets/all'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tickets = data['data'] ?? data;
      return tickets.map((json) => SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<SupportTicket>> getUserTickets(int userId) async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/support/tickets?userId=$userId'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tickets = data['data'] ?? data;
      return tickets.map((json) => SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load user tickets');
  }

  static Future<SupportTicket> updateTicketStatus(int id, String status) async {
    final response = await ioClient.put(
      Uri.parse('$baseUrl/support/ticket/$id/status'),
      headers: getHeaders(),
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SupportTicket.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  // Analytics
  static Future<Map<String, dynamic>> getSalesReport() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/reports/sales'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    }
    throw Exception('Failed to load sales report');
  }

  static Future<Map<String, dynamic>> getInventoryReport() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/reports/inventory'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    }
    throw Exception('Failed to load inventory report');
  }

  static Future<Map<String, dynamic>> getUsersReport() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/reports/users'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    }
    throw Exception('Failed to load users report');
  }

  // Users (Admin only)
  static Future<List<User>> getAllUsers() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/users'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> users = data['data'] ?? [];
        return users.map((json) => User.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load users');
  }

  // Orders
  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await ioClient.post(
        Uri.parse('$baseUrl/orders'),
        headers: getHeaders(),
        body: json.encode(orderData),
      );

      print('Order Response Status: ${response.statusCode}');
      print('Order Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Check if response has success field
        if (data['success'] == true) {
          return Order.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create order');
        }
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      print('Create Order Error: $e');
      rethrow;
    }
  }

  // Users (Admin only)
  static Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await ioClient.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: json.encode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create user');
  }

  static Future<User> updateUserRole(int userId, String role) async {
    final response = await ioClient.put(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: getHeaders(),
      body: json.encode({'role': role}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
    }
    throw Exception('Failed to update user role');
  }

  static Future<void> deleteUser(int userId) async {
    final response = await ioClient.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // Support Tickets
  static Future<SupportTicket> createSupportTicket(
      Map<String, dynamic> ticketData) async {
    try {
      final response = await ioClient.post(
        Uri.parse('$baseUrl/support/ticket'),
        headers: getHeaders(),
        body: json.encode(ticketData),
      );

      print('Create Ticket Status: ${response.statusCode}');
      print('Create Ticket Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SupportTicket.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create support ticket');
    } catch (e) {
      print('Create Ticket Error: $e');
      rethrow;
    }
  }

  // Prescriptions
  static Future<Prescription> uploadPrescription(
      Map<String, dynamic> prescriptionData) async {
    try {
      // Build query parameters
      final queryParams = {
        'userId': prescriptionData['userId'].toString(),
        'fileName': prescriptionData['fileName'],
        'fileType': prescriptionData['fileType'],
        'doctorName': prescriptionData['doctorName'],
        if (prescriptionData['notes'] != null)
          'notes': prescriptionData['notes'],
      };

      final uri = Uri.parse('$baseUrl/prescriptions/upload')
          .replace(queryParameters: queryParams);

      print('Upload Prescription URL: $uri');

      final response = await ioClient.post(
        uri,
        headers: getHeaders(),
      );

      print('Upload Prescription Status: ${response.statusCode}');
      print('Upload Prescription Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Prescription.fromJson(data['data']);
        }
      }
      throw Exception('Failed to upload prescription');
    } catch (e) {
      print('Upload Prescription Error: $e');
      rethrow;
    }
  }

  static Future<List<Prescription>> getAllPrescriptions() async {
    try {
      final response = await ioClient.get(
        Uri.parse('$baseUrl/prescriptions'),
        headers: getHeaders(),
      );

      print('Get All Prescriptions Status: ${response.statusCode}');
      print('Get All Prescriptions Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> prescriptions = data['data'] ?? [];
          return prescriptions
              .map((json) => Prescription.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get All Prescriptions Error: $e');
      return [];
    }
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('Calling dashboard stats API...');
      print('URL: $baseUrl/dashboard/stats');
      print('Token: $authToken');

      final response = await ioClient.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: getHeaders(),
      );

      print('Dashboard Stats Status: ${response.statusCode}');
      print('Dashboard Stats Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    } catch (e) {
      print('Dashboard Stats Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/dashboard/analytics'),
      headers: getHeaders(),
    );

    print('Analytics Status: ${response.statusCode}');
    print('Analytics Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      }
    }
    throw Exception('Failed to load analytics');
  }

  // Payments
  static Future<Payment> initiatePayment(
      Map<String, dynamic> paymentData) async {
    final response = await ioClient.post(
      Uri.parse('$baseUrl/payments/initiate'),
      headers: getHeaders(),
      body: json.encode(paymentData),
    );

    print('Initiate Payment Status: ${response.statusCode}');
    print('Initiate Payment Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Payment.fromJson(data['data']);
      }
    }
    throw Exception('Failed to initiate payment');
  }

  static Future<Payment> verifyPayment(int paymentId) async {
    final response = await ioClient.post(
      Uri.parse('$baseUrl/payments/verify'),
      headers: getHeaders(),
      body: json.encode({'paymentId': paymentId}),
    );

    print('Verify Payment Status: ${response.statusCode}');
    print('Verify Payment Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Payment.fromJson(data['data']);
      }
    }
    throw Exception('Failed to verify payment');
  }

  static Future<List<Payment>> getPaymentHistory(int userId) async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/payments/history?userId=$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> payments = data['data'] ?? [];
        return payments.map((json) => Payment.fromJson(json)).toList();
      }
    }
    return [];
  }

// Notifications
  static Future<List<NotificationModel>> getUserNotifications(
      int userId) async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/notifications/$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> notifications = data['data'] ?? [];
        return notifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  static Future<List<NotificationModel>> getUnreadNotifications(
      int userId) async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/notifications/$userId/unread'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> notifications = data['data'] ?? [];
        return notifications
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    await ioClient.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: getHeaders(),
    );
  }

// Reviews
  static Future<void> createReview(Map<String, dynamic> reviewData) async {
    final response = await ioClient.post(
      Uri.parse('$baseUrl/reviews'),
      headers: getHeaders(),
      body: json.encode(reviewData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit review');
    }
  }

  static Future<Map<String, dynamic>> getProductReviews(int productId) async {
    final response = await ioClient.get(
      Uri.parse('$baseUrl/reviews/$productId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      }
    }
    return {
      'reviews': [],
      'averageRating': 0.0,
      'totalReviews': 0,
    };
  }

// Chat
  static Future<User> getPharmacistForChat() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/pharmacist'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
    }
    throw Exception('No pharmacist available');
  }

  static Future<List<ChatMessage>> getConversation(int otherUserId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversation/$otherUserId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> messages = data['data'] ?? [];
        return messages.map((json) => ChatMessage.fromJson(json)).toList();
      }
    }
    return [];
  }

  static Future<ChatMessage> sendChatMessage(
      int receiverId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: getHeaders(),
      body: json.encode({
        'receiverId': receiverId,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return ChatMessage.fromJson(data['data']);
      }
    }
    throw Exception('Failed to send message');
  }

  static Future<List<User>> getChatConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> users = data['data'] ?? [];
        return users.map((json) => User.fromJson(json)).toList();
      }
    }
    return [];
  }
}
*/
