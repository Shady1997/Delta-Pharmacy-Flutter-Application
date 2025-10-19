import 'package:flutter_test/flutter_test.dart';

import '../../models/order.dart';
import '../../models/payment.dart';
import '../../models/prescription.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../models/support_ticket.dart';
import '../../models/user.dart';
import '../../models/notification.dart';


void main() {
  group('User Model Tests', () {
    test('User.fromJson creates valid User object', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'phoneNumber': '+1234567890',
        'role': 'ADMIN',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.phoneNumber, '+1234567890');
      expect(user.role, 'ADMIN');
    });

    test('User.toJson creates valid JSON', () {
      final user = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+1234567890',
        role: 'ADMIN',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['fullName'], 'Test User');
      expect(json['phoneNumber'], '+1234567890');
      expect(json['role'], 'ADMIN');
    });

    test('User handles null values', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
      };

      final user = User.fromJson(json);

      expect(user.fullName, '');
      expect(user.phoneNumber, '');
      expect(user.role, 'CUSTOMER');
    });
  });

  group('Product Model Tests', () {
    test('Product.fromJson creates valid Product object', () {
      final json = {
        'id': 1,
        'name': 'Aspirin',
        'description': 'Pain reliever',
        'price': 9.99,
        'stockQuantity': 100,
        'category': 'Pain Relief',
        'prescriptionRequired': false,
        'manufacturer': 'PharmaCorp',
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'Aspirin');
      expect(product.description, 'Pain reliever');
      expect(product.price, 9.99);
      expect(product.stockQuantity, 100);
      expect(product.category, 'Pain Relief');
      expect(product.prescriptionRequired, false);
      expect(product.manufacturer, 'PharmaCorp');
    });

    test('Product handles null and default values', () {
      final json = {
        'id': 1,
        'name': 'Test Product',
      };

      final product = Product.fromJson(json);

      expect(product.description, '');
      expect(product.price, 0.0);
      expect(product.stockQuantity, 0);
      expect(product.category, '');
      expect(product.prescriptionRequired, false);
      expect(product.manufacturer, null);
    });

    test('Product toJson creates valid JSON', () {
      final product = Product(
        id: 1,
        name: 'Aspirin',
        description: 'Pain reliever',
        price: 9.99,
        stockQuantity: 100,
        category: 'Pain Relief',
        prescriptionRequired: false,
        manufacturer: 'PharmaCorp',
      );

      final json = product.toJson();

      expect(json['name'], 'Aspirin');
      expect(json['price'], 9.99);
      expect(json['stockQuantity'], 100);
    });
  });

  group('Order Model Tests', () {
    test('Order.fromJson creates valid Order object', () {
      final json = {
        'id': 1,
        'userId': 123,
        'orderDate': '2024-01-01T10:00:00',
        'totalAmount': 99.99,
        'status': 'PENDING',
        'deliveryAddress': '123 Main St',
        'items': [
          {'productId': 1, 'quantity': 2}
        ],
      };

      final order = Order.fromJson(json);

      expect(order.id, 1);
      expect(order.userId, 123);
      expect(order.orderDate, '2024-01-01T10:00:00');
      expect(order.totalAmount, 99.99);
      expect(order.status, 'PENDING');
      expect(order.deliveryAddress, '123 Main St');
      expect(order.items.length, 1);
    });

    test('Order handles empty items', () {
      final json = {
        'id': 1,
        'userId': 123,
        'orderDate': '2024-01-01',
        'totalAmount': 0.0,
        'status': 'PENDING',
        'deliveryAddress': '123 Main St',
      };

      final order = Order.fromJson(json);

      expect(order.items, []);
    });
  });

  group('Prescription Model Tests', () {
    test('Prescription.fromJson creates valid object', () {
      final json = {
        'id': 1,
        'userId': 123,
        'fileName': 'prescription.pdf',
        'status': 'PENDING',
        'doctorName': 'Dr. Smith',
        'notes': 'Take twice daily',
        'uploadedAt': '2024-01-01T10:00:00',
        'reviewedBy': 'Pharmacist',
      };

      final prescription = Prescription.fromJson(json);

      expect(prescription.id, 1);
      expect(prescription.userId, 123);
      expect(prescription.fileName, 'prescription.pdf');
      expect(prescription.status, 'PENDING');
      expect(prescription.doctorName, 'Dr. Smith');
      expect(prescription.notes, 'Take twice daily');
      expect(prescription.uploadedAt, '2024-01-01T10:00:00');
      expect(prescription.reviewedBy, 'Pharmacist');
    });

    test('Prescription handles null optional fields', () {
      final json = {
        'id': 1,
        'userId': 123,
        'fileName': 'prescription.pdf',
        'status': 'PENDING',
        'uploadedAt': '2024-01-01T10:00:00',
      };

      final prescription = Prescription.fromJson(json);

      expect(prescription.doctorName, null);
      expect(prescription.notes, null);
      expect(prescription.reviewedBy, null);
    });
  });

  group('SupportTicket Model Tests', () {
    test('SupportTicket.fromJson creates valid object', () {
      final json = {
        'id': 1,
        'userId': 123,
        'subject': 'Order Issue',
        'description': 'Product not received',
        'status': 'OPEN',
        'createdAt': '2024-01-01T10:00:00',
        'response': 'We are looking into it',
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.id, 1);
      expect(ticket.userId, 123);
      expect(ticket.subject, 'Order Issue');
      expect(ticket.description, 'Product not received');
      expect(ticket.status, 'OPEN');
      expect(ticket.createdAt, '2024-01-01T10:00:00');
      expect(ticket.response, 'We are looking into it');
    });

    test('SupportTicket handles default status', () {
      final json = {
        'id': 1,
        'userId': 123,
        'subject': 'Test',
        'description': 'Test',
        'createdAt': '2024-01-01',
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.status, 'OPEN');
      expect(ticket.response, null);
    });
  });

  group('Payment Model Tests', () {
    test('Payment.fromJson creates valid object', () {
      final json = {
        'id': 1,
        'orderId': 100,
        'userId': 123,
        'amount': 99.99,
        'paymentMethod': 'CREDIT_CARD',
        'status': 'COMPLETED',
        'transactionId': 'TXN123',
        'createdAt': '2024-01-01T10:00:00',
      };

      final payment = Payment.fromJson(json);

      expect(payment.id, 1);
      expect(payment.orderId, 100);
      expect(payment.userId, 123);
      expect(payment.amount, 99.99);
      expect(payment.paymentMethod, 'CREDIT_CARD');
      expect(payment.status, 'COMPLETED');
      expect(payment.transactionId, 'TXN123');
      expect(payment.createdAt, '2024-01-01T10:00:00');
    });
  });

  group('Notification Model Tests', () {
    test('Notification.fromJson creates valid object', () {
      final json = {
        'id': 1,
        'userId': 123,
        'title': 'Order Update',
        'message': 'Your order has been shipped',
        'isRead': false,
        'createdAt': '2024-01-01T10:00:00',
      };

      final notification = Notification.fromJson(json);

      expect(notification.id, 1);
      expect(notification.userId, 123);
      expect(notification.title, 'Order Update');
      expect(notification.message, 'Your order has been shipped');
      expect(notification.isRead, false);
      expect(notification.createdAt, '2024-01-01T10:00:00');
    });

    test('Notification defaults isRead to false', () {
      final json = {
        'id': 1,
        'userId': 123,
        'title': 'Test',
        'message': 'Test message',
        'createdAt': '2024-01-01',
      };

      final notification = Notification.fromJson(json);

      expect(notification.isRead, false);
    });
  });

  group('Review Model Tests', () {
    test('Review.fromJson creates valid object', () {
      final json = {
        'id': 1,
        'productId': 100,
        'userId': 123,
        'rating': 5,
        'comment': 'Great product!',
        'createdAt': '2024-01-01T10:00:00',
      };

      final review = Review.fromJson(json);

      expect(review.id, 1);
      expect(review.productId, 100);
      expect(review.userId, 123);
      expect(review.rating, 5);
      expect(review.comment, 'Great product!');
      expect(review.createdAt, '2024-01-01T10:00:00');
    });

    test('Review handles empty comment', () {
      final json = {
        'id': 1,
        'productId': 100,
        'userId': 123,
        'rating': 4,
        'createdAt': '2024-01-01',
      };

      final review = Review.fromJson(json);

      expect(review.comment, '');
    });
  });
}