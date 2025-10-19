import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class OrderStatusDialog extends StatefulWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const OrderStatusDialog({
    Key? key,
    required this.currentStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<OrderStatusDialog> createState() => _OrderStatusDialogState();
}

class _OrderStatusDialogState extends State<OrderStatusDialog> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select new status for this order:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Status',
            ),
            items: AppConfig.orderStatuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onStatusChanged(_selectedStatus);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }
}