import 'package:flutter/material.dart';

enum MessageType { success, error, warning, info }

class MessageBanner extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onDismiss;
  final bool isDismissible;

  const MessageBanner({
    Key? key,
    required this.message,
    required this.type,
    this.onDismiss,
    this.isDismissible = true,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade50;
      case MessageType.error:
        return Colors.red.shade50;
      case MessageType.warning:
        return Colors.orange.shade50;
      case MessageType.info:
        return Colors.blue.shade50;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade500;
      case MessageType.error:
        return Colors.red.shade500;
      case MessageType.warning:
        return Colors.orange.shade500;
      case MessageType.info:
        return Colors.blue.shade500;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade700;
      case MessageType.error:
        return Colors.red.shade700;
      case MessageType.warning:
        return Colors.orange.shade700;
      case MessageType.info:
        return Colors.blue.shade700;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.error:
        return Icons.error;
      case MessageType.warning:
        return Icons.warning;
      case MessageType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border(
          left: BorderSide(color: _getBorderColor(), width: 4),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getTextColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isDismissible && onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: _getTextColor(),
                size: 20,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class MessageSnackBar {
  static void show(
      BuildContext context,
      String message,
      MessageType type,
      ) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static IconData _getIcon(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle;
      case MessageType.error:
        return Icons.error;
      case MessageType.warning:
        return Icons.warning;
      case MessageType.info:
        return Icons.info;
    }
  }

  static Color _getBackgroundColor(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade600;
      case MessageType.error:
        return Colors.red.shade600;
      case MessageType.warning:
        return Colors.orange.shade600;
      case MessageType.info:
        return Colors.blue.shade600;
    }
  }
}