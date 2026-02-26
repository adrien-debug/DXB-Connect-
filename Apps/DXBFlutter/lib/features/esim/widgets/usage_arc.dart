import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class UsageArc extends StatelessWidget {
  final double progress;
  final double size;
  final double lineWidth;
  final Widget child;

  const UsageArc({
    super.key,
    required this.progress,
    this.size = 150,
    this.lineWidth = 10,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (_, animatedProgress, __) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ArcPainter(
                  progress: animatedProgress,
                  lineWidth: lineWidth,
                  trackColor: Colors.white.withValues(alpha: 0.05),
                  progressColor: AppColors.accent,
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final double lineWidth;
  final Color trackColor;
  final Color progressColor;

  _ArcPainter({
    required this.progress,
    required this.lineWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - lineWidth - 8) / 2;
    const startAngle = -pi / 2;
    const sweepFull = 2 * pi * 0.75;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    if (progress > 0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth + 8
        ..strokeCap = StrokeCap.round
        ..color = progressColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepFull * progress,
        false,
        glowPaint,
      );

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepFull,
          colors: [
            progressColor,
            const Color(0xFFD4FF66),
            progressColor.withValues(alpha: 0.7),
          ],
          stops: const [0, 0.5, 1],
          transform: const GradientRotation(-pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepFull * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
