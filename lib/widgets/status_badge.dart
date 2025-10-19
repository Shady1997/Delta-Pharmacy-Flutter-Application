import 'package:flutter/material.dart';
import '../utils/status_helper.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String type; // 'order', 'prescription', 'ticket', 'payment'

  const StatusBadge({
    Key? key,
    required this.status,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (type) {
      case 'order':
        color = StatusHelper.getOrderStatusColor(status);
        break;
      case 'prescription':
        color = StatusHelper.getPrescriptionStatusColor(status);
        break;
      case 'ticket':
        color = StatusHelper.getTicketStatusColor(status);
        break;
      case 'payment':
        color = StatusHelper.getPaymentStatusColor(status);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}