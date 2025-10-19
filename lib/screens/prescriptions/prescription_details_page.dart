import 'package:flutter/material.dart';
import '../../models/prescription.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';

class PrescriptionDetailsPage extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionDetailsPage({Key? key, required this.prescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription #${prescription.id}'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Prescription Information',
              [
                _buildInfoRow('Prescription ID', prescription.id.toString()),
                _buildInfoRow('User ID', prescription.userId.toString()),
                _buildInfoRow('File Name', prescription.fileName),
                _buildInfoRow('Doctor Name', prescription.doctorName ?? 'N/A'),
                _buildInfoRow(
                  'Uploaded At',
                  DateFormatter.formatDateTime(prescription.uploadedAt),
                ),
                _buildInfoRow('Reviewed By', prescription.reviewedBy ?? 'Pending'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Status',
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    StatusBadge(status: prescription.status, type: 'prescription'),
                  ],
                ),
              ],
            ),
            if (prescription.notes != null && prescription.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildInfoCard(
                  'Notes',
                  [
                    Text(
                      prescription.notes!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}