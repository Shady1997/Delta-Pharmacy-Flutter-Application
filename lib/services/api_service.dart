import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../models/prescription.dart';
import '../models/product.dart';
import '../models/support_ticket.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static String? authToken;

  // Auth
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      authToken = data['data']['token'];
      return data;
    }
    throw Exception(response.body);
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> products = data['data'];
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
    if (response.statusCode == 200) {
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
    if (response.statusCode != 200) {
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
      List<dynamic> products = data['data'];
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
      List<dynamic> orders = data['data'];
      return orders.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to load orders');
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
      List<dynamic> prescriptions = data['data'];
      return prescriptions.map((json) => Prescription.fromJson(json)).toList();
    }
    throw Exception('Failed to load prescriptions');
  }

  static Future<Prescription> approvePrescription(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/prescriptions/$id/approve'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Prescription.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  static Future<Prescription> rejectPrescription(int id, String reason) async {
    final response = await http.put(
      Uri.parse('$baseUrl/prescriptions/$id/reject'),
      headers: _getHeaders(),
      body: json.encode({'reason': reason}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Prescription.fromJson(data['data']);
    }
    throw Exception(response.body);
  }

  // Support Tickets
  static Future<List<SupportTicket>> getAllTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/tickets/all'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tickets = data['data'];
      return tickets.map((json) => SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load tickets');
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
      return data['data'];
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
      return data['data'];
    }
    throw Exception('Failed to load inventory report');
  }
}