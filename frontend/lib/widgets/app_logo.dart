import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  const AppLogo({super.key, this.size = 64, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(Icons.local_taxi_rounded, color: Colors.white, size: size * 0.55),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          const Text(AppConstants.appName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        ],
      ],
    );
  }
}
