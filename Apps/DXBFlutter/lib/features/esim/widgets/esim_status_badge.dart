import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EsimStatusBadge extends StatelessWidget {
  final String status;

  const EsimStatusBadge({super.key, required this.status});

  static bool isActiveStatus(String status) {
    final upper = status.toUpperCase();
    return ['RELEASED', 'IN_USE', 'ENABLED', 'ACTIVE'].contains(upper);
  }

  static String statusLabel(String status) {
    final upper = status.toUpperCase();
    switch (upper) {
      case 'RELEASED':
      case 'IN_USE':
      case 'ENABLED':
      case 'ACTIVE':
        return 'ACTIVE';
      case 'DISABLED':
      case 'SUSPENDED':
        return 'PAUSED';
      case 'DELETED':
        return 'EXPIRED';
      default:
        return upper;
    }
  }

  static Color statusColor(String status) {
    if (isActiveStatus(status)) return AppColors.accent;
    final upper = status.toUpperCase();
    if (upper == 'DISABLED' || upper == 'SUSPENDED') return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final active = isActiveStatus(status);
    final color = statusColor(status);
    final label = statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          color: active ? Colors.black : AppColors.textPrimary,
        ),
      ),
    );
  }
}
