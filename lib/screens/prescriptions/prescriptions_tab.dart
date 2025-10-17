class PrescriptionsTab extends StatefulWidget {
  final Function(String, bool) onMessage;

  const PrescriptionsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  State<PrescriptionsTab> createState() => _PrescriptionsTabState();
}

class _PrescriptionsTabState extends State<PrescriptionsTab> {
  List<Prescription> prescriptions = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => loading = true);
    try {
      final fetchedPrescriptions = await ApiService.getPendingPrescriptions();
      setState(() => prescriptions = fetchedPrescriptions);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _approvePrescription(int id) async {
    setState(() => loading = true);
    try {
      await ApiService.approvePrescription(id);
      await _loadPrescriptions();
      widget.onMessage('Prescription approved!', false);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _rejectPrescription(int id, String reason) async {
    setState(() => loading = true);
    try {
      await ApiService.rejectPrescription(id, reason);
      await _loadPrescriptions();
      widget.onMessage('Prescription rejected!', false);
    } catch (e) {
      widget.onMessage(e.toString(), true);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prescription Review',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _loadPrescriptions,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
                  'Pending Prescriptions (${prescriptions.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.purple.shade100),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('User ID')),
                      DataColumn(label: Text('File Name')),
                      DataColumn(label: Text('Doctor')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Uploaded At')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: prescriptions
                        .map(
                          (prescription) => DataRow(
                        cells: [
                          DataCell(Text(prescription.id.toString())),
                          DataCell(Text(prescription.userId.toString())),
                          DataCell(Text(prescription.fileName)),
                          DataCell(Text(prescription.doctorName ?? 'N/A')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: prescription.status == 'PENDING'
                                    ? Colors.orange.shade200
                                    : prescription.status == 'APPROVED'
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                prescription.status,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          DataCell(Text(
                              prescription.uploadedAt.split('T')[0])),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () =>
                                      _approvePrescription(prescription.id),
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () => _showRejectDialog(
                                      prescription.id),
                                  tooltip: 'Reject',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
                if (prescriptions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No pending prescriptions',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(int id) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Prescription'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectPrescription(id, reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}