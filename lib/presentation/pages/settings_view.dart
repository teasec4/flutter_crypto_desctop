import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 30),
              _buildSettingSection(
                title: 'Notifications',
                children: [
                  _buildSwitchTile(
                    title: 'Enable notifications',
                    subtitle: 'Get notifications about price changes',
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() => notificationsEnabled = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSettingSection(
                title: 'Appearance',
                children: [
                  _buildSwitchTile(
                    title: 'Dark mode',
                    subtitle: 'Switch to dark theme',
                    value: darkModeEnabled,
                    onChanged: (value) {
                      setState(() => darkModeEnabled = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSettingSection(
                title: 'Currency',
                children: [
                  _buildDropdownTile(
                    title: 'Select currency',
                    value: selectedCurrency,
                    items: ['USD', 'EUR', 'RUB', 'GBP'],
                    onChanged: (value) {
                      setState(() => selectedCurrency = value ?? 'USD');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSettingSection(
                title: 'About',
                children: [
                  _buildInfoTile(
                    title: 'Version',
                    value: '1.0.0',
                  ),
                  const Divider(),
                  _buildInfoTile(
                    title: 'API',
                    value: 'CoinGecko API',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          DropdownButton<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
