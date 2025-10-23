class Payment {
  final int id;
  final int orderId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final String? cardLastFourDigits;
  final String createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.cardLastFourDigits,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      orderId: json['order']?['id'] ?? json['orderId'] ?? 0,
      userId: json['user']?['id'] ?? json['userId'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'PENDING',
      transactionId: json['transactionId'],
      cardLastFourDigits: json['cardLastFourDigits'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'cardLastFourDigits': cardLastFourDigits,
      'createdAt': createdAt,
    };
  }
}