class Review {
  final int id;
  final int productId;
  final int userId;
  final int rating;
  final String comment;
  final String createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}