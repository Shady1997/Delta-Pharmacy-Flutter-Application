class Order {
  final int id;
  final int userId;
  final String orderDate;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final List<dynamic> items;

  Order({
    required this.id,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      orderDate: json['orderDate'] ?? '',
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      deliveryAddress: json['deliveryAddress'] ?? '',
      items: json['items'] ?? [],
    );
  }
}