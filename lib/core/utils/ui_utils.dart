import 'package:flutter/material.dart';

/// Utility functions for UI styling and formatting
class UIUtils {
  /// Gets the secondary text color based on the current theme
  /// Returns grey.shade400 in dark mode, grey.shade700 in light mode
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.grey.shade400;
    } else {
      return Colors.grey.shade700;
    }
  }

  /// Formats a market cap rank into a display string
  /// Returns empty string if rank is 0, otherwise returns the rank number as string
  static String formatRank(int rank) {
    if (rank == 0) return '';
    return '$rank';
  }
}
