import 'package:flutter/material.dart';

class DataTableWrapper extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String emptyMessage;
  final Color? headingRowColor;
  final bool showBorder;

  const DataTableWrapper({
    Key? key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No data available',
    this.headingRowColor,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: showBorder ? Border.all(color: Colors.grey.shade300) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            headingRowColor ?? Colors.blue.shade100,
          ),
          columns: columns,
          rows: rows,
          columnSpacing: 24,
          horizontalMargin: 16,
          dataRowHeight: 56,
          headingRowHeight: 56,
          dividerThickness: 1,
          showBottomBorder: showBorder,
        ),
      ),
    );
  }
}

class ResponsiveDataTable extends StatelessWidget {
  final String title;
  final int itemCount;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String emptyMessage;
  final Widget? actionButton;

  const ResponsiveDataTable({
    Key? key,
    required this.title,
    required this.itemCount,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No data available',
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title ($itemCount)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (actionButton != null) actionButton!,
            ],
          ),
          const SizedBox(height: 16),
          DataTableWrapper(
            columns: columns,
            rows: rows,
            emptyMessage: emptyMessage,
          ),
        ],
      ),
    );
  }
}