import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
