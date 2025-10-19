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
      userId: json['userId'] ?? json['user']?['id'] ?? 0,  // ← FIX HERE: Extract from user object
      orderDate: json['createdAt'] ?? json['orderDate'] ?? '',  // ← FIX: Backend uses 'createdAt'
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      deliveryAddress: json['shippingAddress'] ?? json['deliveryAddress'] ?? '',  // ← FIX: Backend uses 'shippingAddress'
      items: json['items'] ?? [],
    );
  }
}