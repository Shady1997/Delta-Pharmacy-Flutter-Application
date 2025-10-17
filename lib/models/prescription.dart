class Prescription {
  final int id;
  final int userId;
  final String fileName;
  final String status;
  final String? doctorName;
  final String? notes;
  final String uploadedAt;
  final String? reviewedBy;

  Prescription({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.status,
    this.doctorName,
    this.notes,
    required this.uploadedAt,
    this.reviewedBy,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      userId: json['userId'],
      fileName: json['fileName'],
      status: json['status'] ?? 'PENDING',
      doctorName: json['doctorName'],
      notes: json['notes'],
      uploadedAt: json['uploadedAt'] ?? '',
      reviewedBy: json['reviewedBy'],
    );
  }
}