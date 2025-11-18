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

  // Supabase tables and columns
  static const String portfolioTable = 'portfolio';
  static const String profilesTable = 'profiles';

  // Supabase column names
  static const String userId = 'user_id';
  static const String id = 'id';
  static const String amount = 'amount';
  static const String symbol = 'symbol';
  static const String email = 'email';
  static const String displayName = 'display_name';
  static const String createdAt = 'created_at';

  // CoinGecko API
  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String coinGeckoMarketsEndpoint = '/coins/markets';
  static const String coinGeckoChartEndpoint = '/coins/{id}/market_chart';
}
