import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/prescription.dart';
import '../../models/user.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import '../prescriptions/prescription_details_page.dart';
import '../prescriptions/prescription_review_dialog.dart';

class PrescriptionsTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const PrescriptionsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<PrescriptionsTab> createState() => _PrescriptionsTabState();
}

class _PrescriptionsTabState extends State<PrescriptionsTab> {
  List<Prescription> _prescriptions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final user = ApiService.currentUser;
      if (user == null) return;

      List<Prescription> prescriptions;
      if (user.canApprovePrescriptions()) {
        prescriptions = await ApiService.getPendingPrescriptions();
      } else {
        prescriptions = await ApiService.getUserPrescriptions(user.id);
      }

      setState(() => _prescriptions = prescriptions);
    } catch (e) {
      widget.onMessage('Failed to load prescriptions: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReview(
      int prescriptionId, bool approve, String? reason) async {
    try {
      if (approve) {
        await ApiService.approvePrescription(prescriptionId);
        widget.onMessage('Prescription approved successfully', false);
      } else {
        await ApiService.rejectPrescription(prescriptionId, reason ?? '');
        widget.onMessage('Prescription rejected', false);
      }
      _loadPrescriptions();
    } catch (e) {
      widget.onMessage('Failed to update prescription: ${e.toString()}', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.canApprovePrescriptions() == true
                        ? 'Prescriptions Review'
                        : 'My Prescriptions',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.canApprovePrescriptions() == true
                        ? 'Review and approve customer prescriptions'
                        : 'View your uploaded prescriptions',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Prescriptions Table
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescriptions (${_prescriptions.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _prescriptions.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No prescriptions found'),
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.purple.shade100,
                    ),
                    columns: [
                      const DataColumn(label: Text('ID')),
                      if (user?.canApprovePrescriptions() == true)
                        const DataColumn(label: Text('User ID')),
                      const DataColumn(label: Text('File Name')),
                      const DataColumn(label: Text('Doctor')),
                      const DataColumn(label: Text('Uploaded')),
                      const DataColumn(label: Text('Status')),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: _prescriptions.map((prescription) {
                      return DataRow(
                        cells: [
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PrescriptionDetailsPage(
                                            prescription: prescription),
                                  ),
                                );
                              },
                              child: Text(
                                prescription.id.toString(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          if (user?.canApprovePrescriptions() == true)
                            DataCell(
                                Text(prescription.userId.toString())),
                          DataCell(Text(prescription.fileName)),
                          DataCell(
                              Text(prescription.doctorName ?? 'N/A')),
                          DataCell(Text(DateFormatter.formatDate(
                              prescription.uploadedAt))),
                          DataCell(
                            StatusBadge(
                              status: prescription.status,
                              type: 'prescription',
                            ),
                          ),
                          DataCell(
                            user?.canApprovePrescriptions() == true &&
                                prescription.status == 'PENDING'
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) =>
                                        PrescriptionReviewDialog(
                                          prescriptionId:
                                          prescription.id,
                                          onReview: _handleReview,
                                        ),
                                  ),
                                  tooltip: 'Review',
                                ),
                              ],
                            )
                                : IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PrescriptionDetailsPage(
                                            prescription:
                                            prescription),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}