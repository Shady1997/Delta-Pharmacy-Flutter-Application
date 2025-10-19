import 'package:flutter/material.dart';
import '../../models/support_ticket.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';

class TicketDetailsPage extends StatelessWidget {
  final SupportTicket ticket;

  const TicketDetailsPage({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${ticket.id}'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Ticket Information',
              [
                _buildInfoRow('Ticket ID', ticket.id.toString()),
                _buildInfoRow('User ID', ticket.userId.toString()),
                _buildInfoRow('Subject', ticket.subject),
                _buildInfoRow(
                  'Created At',
                  DateFormatter.formatDateTime(ticket.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Status',
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    StatusBadge(status: ticket.status, type: 'ticket'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Description',
              [
                Text(
                  ticket.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
            if (ticket.response != null && ticket.response!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildInfoCard(
                  'Response',
                  [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.response!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}