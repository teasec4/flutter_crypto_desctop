import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Responsive layout breakpoints
  static const double wideLayoutBreakpoint = 1000.0;
  static const double mediumLayoutBreakpoint = 700.0;

  // Navigation
  static const String homeRoute = '/';
  static const String portfolioRoute = '/portfolio';
  static const String settingsRoute = '/settings';

  // Network timeouts
  static const Duration networkTimeout = Duration(seconds: 15);
  static const Duration longNetworkTimeout = Duration(seconds: 30);

  // Portfolio constants
  static const String portfolioTable = 'portfolio';
}

