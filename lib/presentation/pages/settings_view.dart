import 'package:crypto_desctop/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Notifications Section
          Padding(padding: const EdgeInsets.only(top: 16,left: 16, bottom: 8),
            child: _buildSectionTitle(context, 'Notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Enable notifications'),
            subtitle: const Text('Get alerts about price changes'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
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
                  onChanged: (value) {
                    context.read<ThemeCubit>().setDarkMode(value);
                  },
                ),
              );
            },
          ),


          // Currency Section
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
