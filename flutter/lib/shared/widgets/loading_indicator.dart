import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 48.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      ),
    );
  }
}
