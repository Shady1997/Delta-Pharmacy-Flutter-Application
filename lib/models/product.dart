class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String category;
  final bool prescriptionRequired;
  final String? manufacturer;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.category,
    required this.prescriptionRequired,
    this.manufacturer,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'] ?? '',
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      manufacturer: json['manufacturer'],
    );
  }
}