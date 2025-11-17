import 'package:crypto_desctop/core/theme/theme_cubit.dart';
import 'package:crypto_desctop/core/utils/ui_utils.dart';
import 'package:crypto_desctop/presentation/pages/auth_cubit.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Settings view with app preferences, theme options, and account management
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // User Profile Header
          _buildUserProfileHeader(context),

          // Notifications Section
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: _buildSectionTitle(context, 'Notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Enable notifications'),
            subtitle: const Text('Get alerts about price changes'),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),

          // Appearance Section
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: _buildSectionTitle(context, 'Appearance'),
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isDark = state is ThemeDark;
              return ListTile(
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark mode'),
                subtitle: const Text('Switch theme'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) async {
                    await context.read<ThemeCubit>().setDarkMode(value);
                  },
                ),
              );
            },
          ),

          // Currency Section (placeholder for future implementation)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: _buildSectionTitle(context, 'Currency'),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Select currency'),
            trailing: SizedBox(
              width: 100,
              child: DropdownButton<String>(
                value: 'USD',
                underline: const SizedBox(),
                items: ['USD', 'EUR', 'RUB', 'GBP']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
          ),

          // About Section
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: _buildSectionTitle(context, 'About'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),

          const ListTile(
            leading: Icon(Icons.api),
            title: Text('API'),
            trailing: Text('CoinGecko'),
          ),

          // Account Section
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: _buildSectionTitle(context, 'Account'),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[600]),
            title: Text('Logout', style: TextStyle(color: Colors.red[600])),
            subtitle: const Text('Sign out from your account'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog and handles user logout
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Clear portfolio state before logout (portfolio data persists on server)
              if (context.mounted) {
                context.read<PortfolioCubit>().clear();
              }
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Builds user profile header with name and sync status
  Widget _buildUserProfileHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String userName = 'User';
        String userEmail = 'Not connected';

        if (authState is AuthAuthenticated) {
          userName = authState.user.displayName.isNotEmpty 
              ? authState.user.displayName 
              : authState.user.email;
          userEmail = authState.user.email;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: UIUtils.getSecondaryTextColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sync status
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Synchronized',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a section header with title text
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: UIUtils.getSecondaryTextColor(context),
      ),
    );
  }
}
