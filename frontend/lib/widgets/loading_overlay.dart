import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool show;
  final Widget child;
  const LoadingOverlay({super.key, required this.show, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (show)
          Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
