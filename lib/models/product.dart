class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stockQuantity;
  final bool prescriptionRequired;
  final String? manufacturer;
  final String? brand;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.category,
    required this.stockQuantity,
    required this.prescriptionRequired,
    this.manufacturer,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      manufacturer: json['manufacturer'],
      brand: json['brand'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stockQuantity': stockQuantity,
      'prescriptionRequired': prescriptionRequired,
      'manufacturer': manufacturer,
      'brand': brand,
    };
  }
}