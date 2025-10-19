import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, success, danger, warning, info }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.blue.shade600;
      case ButtonType.secondary:
        return Colors.grey.shade600;
      case ButtonType.success:
        return Colors.green.shade600;
      case ButtonType.danger:
        return Colors.red.shade600;
      case ButtonType.warning:
        return Colors.orange.shade600;
      case ButtonType.info:
        return Colors.cyan.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(width ?? 0, height ?? 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBackgroundColor: Colors.grey.shade400,
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : icon != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isFullWidth;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.blue.shade600;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        side: BorderSide(color: buttonColor, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: icon != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}