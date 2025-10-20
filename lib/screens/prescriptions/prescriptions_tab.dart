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
  final _fileNameController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedFileType = 'PDF';

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
        // Admin/Pharmacist see ALL prescriptions (not just pending)
        prescriptions = await ApiService.getAllPrescriptions();
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

  Future<void> _handleReview(int prescriptionId, bool approve, String? reason) async {
    try {
      if (approve) {
        await ApiService.approvePrescription(prescriptionId);
        widget.onMessage('Prescription approved successfully', false);
      } else {
        if (reason == null || reason.isEmpty) {
          widget.onMessage('Please provide a rejection reason', true);
          return;
        }
        await ApiService.rejectPrescription(prescriptionId, reason);
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

          // Upload Prescription Form (Customer only)
          if (user?.isCustomer == true) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upload_file, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Prescription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      labelText: 'File Name',
                      hintText: 'prescription.pdf',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                      prefixIcon: const Icon(Icons.file_present),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _doctorNameController,
                          decoration: InputDecoration(
                            labelText: 'Doctor Name',
                            hintText: 'Dr. Smith',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            prefixIcon: const Icon(Icons.medical_services),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFileType,
                          decoration: InputDecoration(
                            labelText: 'File Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          items: ['PDF', 'JPG', 'PNG', 'JPEG']
                              .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedFileType = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional information',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadPrescription,
                      icon: const Icon(Icons.cloud_upload),
                      label: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Upload Prescription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: In production, you would select a file from your device. This is a simplified version.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

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
  Future<void> _uploadPrescription() async {
    final user = ApiService.currentUser;
    if (user == null) {
      widget.onMessage('Please login first', true);
      return;
    }

    if (_fileNameController.text.isEmpty || _doctorNameController.text.isEmpty) {
      widget.onMessage('Please fill all required fields', true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prescriptionData = {
        'userId': user.id,
        'fileName': _fileNameController.text,
        'fileType': _selectedFileType.toLowerCase(),
        'doctorName': _doctorNameController.text,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      };

      await ApiService.uploadPrescription(prescriptionData);
      widget.onMessage('Prescription uploaded successfully!', false);

      // Clear form
      _fileNameController.clear();
      _doctorNameController.clear();
      _notesController.clear();
      setState(() {
        _selectedFileType = 'PDF';
      });

      // Reload prescriptions
      _loadPrescriptions();
    } catch (e) {
      widget.onMessage('Failed to upload prescription: ${e.toString()}', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  void dispose() {
    _fileNameController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}