import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/support_ticket.dart';
import '../../models/user.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import '../support/ticket_details_page.dart';

class SupportTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const SupportTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  List<SupportTicket> _tickets = [];
  bool _isLoading = false;
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'MEDIUM';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final user = ApiService.currentUser;
      if (user == null) return;

      List<SupportTicket> tickets;
      if (user.canRespondToTickets()) {
        tickets = await ApiService.getAllTickets();
      } else {
        tickets = await ApiService.getUserTickets(user.id);
      }

      setState(() => _tickets = tickets);
    } catch (e) {
      widget.onMessage('Failed to load tickets: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTicket() async {
    final user = ApiService.currentUser;
    if (user == null) {
      widget.onMessage('Please login first', true);
      return;
    }

    if (_subjectController.text.isEmpty || _descriptionController.text.isEmpty) {
      widget.onMessage('Please fill all required fields', true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ticketData = {
        'userId': user.id,
        'subject': _subjectController.text,
        'description': _descriptionController.text,
        'priority': _selectedPriority,
      };

      await ApiService.createSupportTicket(ticketData);
      widget.onMessage('Support ticket created successfully!', false);

      // Clear form
      _subjectController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedPriority = 'MEDIUM';
      });

      // Reload tickets
      _loadTickets();
    } catch (e) {
      widget.onMessage('Failed to create ticket: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTicketStatus(int ticketId, String newStatus) async {
    try {
      await ApiService.updateTicketStatus(ticketId, newStatus);
      widget.onMessage('Ticket status updated successfully', false);
      _loadTickets();
    } catch (e) {
      widget.onMessage('Failed to update ticket: ${e.toString()}', true);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return Colors.red.shade100;
      case 'HIGH':
        return Colors.orange.shade100;
      case 'MEDIUM':
        return Colors.blue.shade100;
      case 'LOW':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getPriorityTextColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.orange.shade700;
      case 'MEDIUM':
        return Colors.blue.shade700;
      case 'LOW':
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ListView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.canRespondToTickets() == true
                        ? 'Support Tickets Management'
                        : 'My Support Tickets',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.canRespondToTickets() == true
                        ? 'View and respond to customer support tickets'
                        : 'Create and track your support requests',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Create Ticket Form
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.orange.shade700, size: isMobile ? 18 : 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create Support Ticket',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Brief description of your issue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed description of your issue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: isMobile ? 3 : 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                ),
                items: ['LOW', 'MEDIUM', 'HIGH', 'URGENT']
                    .map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: priority == 'URGENT'
                            ? Colors.red
                            : priority == 'HIGH'
                            ? Colors.orange
                            : priority == 'MEDIUM'
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(priority),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedPriority = value!);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createTicket,
                  icon: const Icon(Icons.send),
                  label: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Submit Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tickets List
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Support Tickets (${_tickets.length})',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _tickets.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No support tickets found'),
                ),
              )
                  : isMobile
                  ? Column(
                children: _tickets.map((ticket) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getPriorityColor(ticket.priority),
                        child: Text(
                          ticket.id.toString(),
                          style: TextStyle(
                            color: _getPriorityTextColor(ticket.priority),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        ticket.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 12,
                                color: _getPriorityTextColor(ticket.priority),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.priority,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getPriorityTextColor(ticket.priority),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              StatusBadge(
                                status: ticket.status,
                                type: 'ticket',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatDate(ticket.createdAt),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: user?.canRespondToTickets() == true
                          ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (status) =>
                            _updateTicketStatus(ticket.id, status),
                        itemBuilder: (context) => [
                          'OPEN',
                          'IN_PROGRESS',
                          'RESOLVED',
                          'CLOSED'
                        ]
                            .map((status) => PopupMenuItem(
                          value: status,
                          child: Text(status, style: const TextStyle(fontSize: 13)),
                        ))
                            .toList(),
                      )
                          : IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TicketDetailsPage(ticket: ticket),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketDetailsPage(ticket: ticket),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.orange.shade100,
                  ),
                  columns: [
                    const DataColumn(label: Text('ID')),
                    if (user?.canRespondToTickets() == true)
                      const DataColumn(label: Text('User ID')),
                    const DataColumn(label: Text('Subject')),
                    const DataColumn(label: Text('Priority')),
                    const DataColumn(label: Text('Status')),
                    const DataColumn(label: Text('Created')),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: _tickets.map((ticket) {
                    return DataRow(
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TicketDetailsPage(ticket: ticket),
                                ),
                              );
                            },
                            child: Text(
                              ticket.id.toString(),
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (user?.canRespondToTickets() == true)
                          DataCell(Text(ticket.userId.toString())),
                        DataCell(
                          SizedBox(
                            width: 200,
                            child: Text(
                              ticket.subject,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(ticket.priority),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 14,
                                  color: _getPriorityTextColor(ticket.priority),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ticket.priority,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getPriorityTextColor(ticket.priority),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          StatusBadge(
                            status: ticket.status,
                            type: 'ticket',
                          ),
                        ),
                        DataCell(Text(
                            DateFormatter.formatDate(ticket.createdAt))),
                        DataCell(
                          user?.canRespondToTickets() == true
                              ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (status) =>
                                _updateTicketStatus(
                                    ticket.id, status),
                            itemBuilder: (context) => [
                              'OPEN',
                              'IN_PROGRESS',
                              'RESOLVED',
                              'CLOSED'
                            ]
                                .map((status) => PopupMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                                .toList(),
                          )
                              : IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TicketDetailsPage(
                                          ticket: ticket),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}