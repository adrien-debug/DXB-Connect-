import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

extension NumExtensions on num {
  String get formatBytes {
    if (this < 1024) return '${toStringAsFixed(0)} B';
    if (this < 1048576) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1073741824) return '${(this / 1048576).toStringAsFixed(1)} MB';
    return '${(this / 1073741824).toStringAsFixed(2)} GB';
  }

  String get formatPrice => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(this);

  String get formatCompact => NumberFormat.compact().format(this);
}

extension DateTimeExtensions on DateTime {
  String get formatShort => DateFormat('MMM d, y').format(this);
  String get formatFull => DateFormat('MMMM d, y HH:mm').format(this);
  String get formatRelative {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  bool get isExpired => isBefore(DateTime.now());
  int get daysLeft => difference(DateTime.now()).inDays;
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  EdgeInsets get padding => mediaQuery.padding;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : null,
      ),
    );
  }
}
