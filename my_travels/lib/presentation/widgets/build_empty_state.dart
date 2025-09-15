// In lib/presentation/widgets/build_empty_state.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Builds a generic empty state widget for use across the application.
///
/// Displays a Lottie animation, a title, a subtitle, and an optional hint text.
///
/// - [context]: The build context.
/// - [lottiePath]: The asset path for the Lottie JSON file.
/// - [title]: The main title text for the empty state.
/// - [subtitle]: The subtitle text displayed below the title.
/// - [hint]: An additional hint or instructional text at the bottom.
Widget buildEmptyState(
  BuildContext context,
  String lottiePath,
  String title,
  String subtitle,
  String hint,
) {
  return Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(lottiePath, width: 200, height: 200),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 56),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    ),
  );
}
