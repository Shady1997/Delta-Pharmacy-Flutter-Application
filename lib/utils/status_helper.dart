import 'package:flutter/material.dart';

class StatusHelper {
  static Color getOrderStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'SHIPPED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color getPrescriptionStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.shade200;
      case 'APPROVED':
        return Colors.green.shade200;
      case 'REJECTED':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  static Color getTicketStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.red.shade200;
      case 'IN_PROGRESS':
        return Colors.orange.shade200;
      case 'RESOLVED':
        return Colors.green.shade200;
      case 'CLOSED':
        return Colors.grey.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  static Color getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static IconData getOrderStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending;
      case 'PROCESSING':
        return Icons.sync;
      case 'SHIPPED':
        return Icons.local_shipping;
      case 'DELIVERED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}