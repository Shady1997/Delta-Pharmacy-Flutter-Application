class SupportTicket {
  final int id;
  final int userId;
  final String subject;
  final String description;
  final String status;
  final String createdAt;
  final String? response;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.response,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      userId: json['userId'],
      subject: json['subject'],
      description: json['description'],
      status: json['status'] ?? 'OPEN',
      createdAt: json['createdAt'] ?? '',
      response: json['response'],
    );
  }
}