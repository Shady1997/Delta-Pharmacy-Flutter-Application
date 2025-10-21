import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/prescription.dart';
import '../models/support_ticket.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.4:8545/pharmacy-api/api';

  static String? get authToken => AuthService.authToken;
  static User? get currentUser => AuthService.currentUser;

  static Map<String, String> _getHeaders() {
    return AuthService.getAuthHeaders();
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await AuthService.login(email, password);
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  static Future<List<Product>> getLowStockProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory/stock-levels'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
        headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
        Uri.parse('$baseUrl/prescriptions/user/$userId'),  // ← Changed endpoint
        headers: _getHeaders(),
      );

      print('Get User Prescriptions Status: ${response.statusCode}');
      print('Get User Prescriptions Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> prescriptions = data['data'] ?? [];
          return prescriptions.map((json) => Prescription.fromJson(json)).toList();
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
        headers: _getHeaders(),
        body: json.encode({'reason': reason}),
      );

      print('Reject Prescription Status: ${response.statusCode}');
      print('Reject Prescription Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't try to parse the response as Prescription object
          return;  // Just return void on success
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
        headers: _getHeaders(),
      );

      print('Approve Prescription Status: ${response.statusCode}');
      print('Approve Prescription Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't try to parse the response as Prescription object
          return;  // Just return void on success
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
        headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
  // Support Tickets
  static Future<SupportTicket> createSupportTicket(Map<String, dynamic> ticketData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/ticket'),
        headers: _getHeaders(),
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
  static Future<Prescription> uploadPrescription(Map<String, dynamic> prescriptionData) async {
    try {
      // Build query parameters
      final queryParams = {
        'userId': prescriptionData['userId'].toString(),
        'fileName': prescriptionData['fileName'],
        'fileType': prescriptionData['fileType'],
        'doctorName': prescriptionData['doctorName'],
        if (prescriptionData['notes'] != null) 'notes': prescriptionData['notes'],
      };

      final uri = Uri.parse('$baseUrl/prescriptions/upload').replace(queryParameters: queryParams);

      print('Upload Prescription URL: $uri');

      final response = await http.post(
        uri,
        headers: _getHeaders(),
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
        headers: _getHeaders(),
      );

      print('Get All Prescriptions Status: ${response.statusCode}');
      print('Get All Prescriptions Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> prescriptions = data['data'] ?? [];
          return prescriptions.map((json) => Prescription.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get All Prescriptions Error: $e');
      return [];
    }
  }

}