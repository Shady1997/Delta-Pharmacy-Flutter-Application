import 'package:flutter/material.dart';

class PrescriptionReviewDialog extends StatefulWidget {
  final int prescriptionId;
  final Function(int, bool, String?) onReview;

  const PrescriptionReviewDialog({
    Key? key,
    required this.prescriptionId,
    required this.onReview,
  }) : super(key: key);

  @override
  State<PrescriptionReviewDialog> createState() =>
      _PrescriptionReviewDialogState();
}

class _PrescriptionReviewDialogState extends State<PrescriptionReviewDialog> {
  final _reasonController = TextEditingController();
  bool _isApproval = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isApproval ? 'Approve Prescription' : 'Reject Prescription'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isApproval = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isApproval ? Colors.green : Colors.grey.shade300,
                    foregroundColor: _isApproval ? Colors.white : Colors.black,
                  ),
                  child: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isApproval = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    !_isApproval ? Colors.red : Colors.grey.shade300,
                    foregroundColor: !_isApproval ? Colors.white : Colors.black,
                  ),
                  child: const Text('Reject'),
                ),
              ),
            ],
          ),
          if (!_isApproval) ...[
            const SizedBox(height: 16),
            const Text('Rejection Reason:'),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_isApproval && _reasonController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter rejection reason')),
              );
              return;
            }
            widget.onReview(
              widget.prescriptionId,
              _isApproval,
              _isApproval ? null : _reasonController.text,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isApproval ? Colors.green : Colors.red,
          ),
          child: Text(_isApproval ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}