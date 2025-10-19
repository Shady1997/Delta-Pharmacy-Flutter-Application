class Payment {
  final int id;
  final int orderId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final String createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'PENDING',
      transactionId: json['transactionId'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}