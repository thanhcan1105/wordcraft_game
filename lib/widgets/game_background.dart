import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Decorative background with gradient sky theme
class GameBackground extends StatelessWidget {
  final Widget child;

  const GameBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyTop,
            AppColors.skyBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}
