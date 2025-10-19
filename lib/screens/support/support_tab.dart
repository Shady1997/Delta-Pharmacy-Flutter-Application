import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/support_ticket.dart';
import '../../services/api_service.dart';

class SupportTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const SupportTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  List<SupportTicket> tickets = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => loading = true);
    try {
      final fetchedTickets = await ApiService.getAllTickets();
      setState(() => tickets = fetchedTickets);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _updateTicketStatus(int id, String status) async {
    setState(() => loading = true);
    try {
      await ApiService.updateTicketStatus(id, status);
      await _loadTickets();
      widget.onMessage('Ticket status updated!', false);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Support Tickets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _loadTickets,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tickets List (${tickets.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                    MaterialStateProperty.all(Colors.orange.shade100),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('User ID')),
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Created At')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: tickets
                        .map(
                          (ticket) => DataRow(
                        cells: [
                          DataCell(Text(ticket.id.toString())),
                          DataCell(Text(ticket.userId.toString())),
                          DataCell(Text(ticket.subject)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ticket.status == 'OPEN'
                                    ? Colors.red.shade200
                                    : ticket.status == 'IN_PROGRESS'
                                    ? Colors.orange.shade200
                                    : Colors.green.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ticket.status,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          DataCell(Text(ticket.createdAt.split('T')[0])),
                          DataCell(
                            PopupMenuButton<String>(
                              onSelected: (status) =>
                                  _updateTicketStatus(ticket.id, status),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'OPEN',
                                  child: Text('Set Open'),
                                ),
                                const PopupMenuItem(
                                  value: 'IN_PROGRESS',
                                  child: Text('Set In Progress'),
                                ),
                                const PopupMenuItem(
                                  value: 'RESOLVED',
                                  child: Text('Set Resolved'),
                                ),
                                const PopupMenuItem(
                                  value: 'CLOSED',
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
                if (tickets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No support tickets',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}