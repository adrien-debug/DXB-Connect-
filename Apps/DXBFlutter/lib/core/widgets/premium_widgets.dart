import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double borderOpacity;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.blur = 12,
    this.borderOpacity = 0.08,
    this.gradientColors,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ??
                  [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.02),
                  ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, val, __) {
        return Text(
          '${val.toInt()}${suffix ?? ''}',
          style: style ??
              const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        );
      },
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    this.color = AppColors.accent,
    this.size = 8,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final scale = 1.0 + (_controller.value * 0.3);
        final opacity = 0.6 - (_controller.value * 0.4);
        return SizedBox(
          width: widget.size * 2.5,
          height: widget.size * 2.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 2,
                  height: widget.size * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: opacity),
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final List<Color>? borderColors;
  final double borderWidth;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderColors,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = borderColors ??
        [
          AppColors.accent.withValues(alpha: 0.6),
          AppColors.accent.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.05),
          AppColors.accent.withValues(alpha: 0.3),
        ];

    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: SweepGradient(colors: colors),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppRadius.xl - borderWidth),
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const StaggeredFadeIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 500),
    this.offsetY = 20,
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _offset = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _offset.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class AnimatedGlowContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlur;

  const AnimatedGlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppColors.accent,
    this.maxBlur = 20,
  });

  @override
  State<AnimatedGlowContainer> createState() => _AnimatedGlowContainerState();
}

class _AnimatedGlowContainerState extends State<AnimatedGlowContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return widget.child;
      },
    );
  }
}

class CircularUsageGauge extends StatefulWidget {
  final double percentage;
  final double size;
  final Color? progressColor;
  final Color? trackColor;
  final String? centerLabel;
  final String? centerValue;

  const CircularUsageGauge({
    super.key,
    required this.percentage,
    this.size = 140,
    this.progressColor,
    this.trackColor,
    this.centerLabel,
    this.centerValue,
  });

  @override
  State<CircularUsageGauge> createState() => _CircularUsageGaugeState();
}

class _CircularUsageGaugeState extends State<CircularUsageGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.percentage / 100),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: value,
              progressColor: widget.progressColor ?? AppColors.accent,
              trackColor:
                  widget.trackColor ?? Colors.white.withValues(alpha: 0.06),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerValue ?? '${(value * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  if (widget.centerLabel != null)
                    Text(
                      widget.centerLabel!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;

  _GaugePainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            progressColor,
            progressColor.withValues(alpha: 0.8),
            progressColor,
          ],
          stops: const [0, 0.5, 1],
          transform: GradientRotation(startAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress;
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ScaleOnTap({super.key, required this.child, this.onTap});

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
