import 'package:flutter/material.dart';

class TicketResponseDialog extends StatefulWidget {
  final int ticketId;
  final Function(int, String) onResponse;

  const TicketResponseDialog({
    Key? key,
    required this.ticketId,
    required this.onResponse,
  }) : super(key: key);

  @override
  State<TicketResponseDialog> createState() => _TicketResponseDialogState();
}

class _TicketResponseDialogState extends State<TicketResponseDialog> {
  final _responseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Response'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter your response to the ticket:'),
          const SizedBox(height: 16),
          TextField(
            controller: _responseController,
            decoration: const InputDecoration(
              hintText: 'Type your response here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
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
            if (_responseController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a response')),
              );
              return;
            }
            widget.onResponse(widget.ticketId, _responseController.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
          ),
          child: const Text('Send Response'),
        ),
      ],
    );
  }
}