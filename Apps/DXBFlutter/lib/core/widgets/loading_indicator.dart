import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({super.key, this.size = 32, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color ?? AppColors.accent,
        ),
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surfaceBorder,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surfaceBorder,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
