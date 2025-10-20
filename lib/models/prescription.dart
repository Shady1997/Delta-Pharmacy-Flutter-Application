class Prescription {
  final int id;
  final int userId;
  final String fileName;
  final String status;
  final String? doctorName;
  final String? notes;
  final String uploadedAt;
  final String? reviewedBy;
  final String? reviewedAt;
  final String? rejectionReason;

  Prescription({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.status,
    this.doctorName,
    this.notes,
    required this.uploadedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? json['user']?['id'] ?? 0,
      fileName: json['fileName'] ?? '',
      status: json['status'] ?? 'PENDING',
      doctorName: json['doctorName'],
      notes: json['notes'],
      uploadedAt: json['uploadedAt'] ?? json['createdAt'] ?? '',
      reviewedBy: json['reviewedBy'] is Map
          ? json['reviewedBy']['fullName']  // ← Extract name from nested object
          : json['reviewedBy'],
      reviewedAt: json['reviewedAt'],
      rejectionReason: json['rejectionReason'],
    );
  }
}