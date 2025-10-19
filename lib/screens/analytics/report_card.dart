import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? data;
  final IconData icon;
  final Color color;

  const ReportCard({
    Key? key,
    required this.title,
    required this.data,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data != null && data!.isNotEmpty)
            ...data!.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatKey(entry.key),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _formatValue(entry.value),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ))
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
    )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return '\$${value.toStringAsFixed(2)}';
    }
    return value.toString();
  }
}