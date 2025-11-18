import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme_manager.dart';
import './widgets/settings_list_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/theme_toggle_widget.dart';

/// Settings screen for app configuration and preferences
class Settings extends StatefulWidget {
  final ThemeManager? themeManager;

  const Settings({
    super.key,
    this.themeManager,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late ThemeManager _themeManager;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _temperatureUnit = 'Celsius';
  final String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _themeManager = widget.themeManager ?? ThemeManager();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Appearance Section
            SettingsSectionWidget(
              title: 'Appearance',
              children: [
                ThemeToggleWidget(
                  themeManager: _themeManager,
                  onThemeModeChanged: () {
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weather Preferences Section
            SettingsSectionWidget(
              title: 'Weather Preferences',
              children: [
                SettingsListItemWidget(
                  icon: Icons.thermostat,
                  title: 'Temperature Unit',
                  subtitle: _temperatureUnit,
                  onTap: () => _showTemperatureUnitDialog(),
                ),
                SettingsListItemWidget(
                  icon: Icons.air,
                  title: 'Wind Speed Unit',
                  subtitle: 'km/h',
                  onTap: () => _showWindSpeedUnitDialog(),
                ),
                SettingsListItemWidget(
                  icon: Icons.compress,
                  title: 'Pressure Unit',
                  subtitle: 'hPa',
                  onTap: () => _showPressureUnitDialog(),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notifications Section
            SettingsSectionWidget(
              title: 'Notifications',
              children: [
                SettingsListItemWidget(
                  icon: Icons.notifications,
                  title: 'Weather Alerts',
                  subtitle: 'Get notified about severe weather',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                SettingsListItemWidget(
                  icon: Icons.schedule,
                  title: 'Daily Forecast',
                  subtitle: 'Daily weather summary at 8:00 AM',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Location Section
            SettingsSectionWidget(
              title: 'Location Services',
              children: [
                SettingsListItemWidget(
                  icon: Icons.location_on,
                  title: 'Location Access',
                  subtitle: _locationEnabled ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: _locationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _locationEnabled = value;
                      });
                    },
                  ),
                ),
                SettingsListItemWidget(
                  icon: Icons.home,
                  title: 'Default City',
                  subtitle: 'Set your home location',
                  onTap: () => _navigateToCitySelection(),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Privacy Section
            SettingsSectionWidget(
              title: 'Data & Privacy',
              children: [
                SettingsListItemWidget(
                  icon: Icons.cached,
                  title: 'Clear Cache',
                  subtitle: 'Remove stored weather data',
                  onTap: () => _showClearCacheDialog(),
                ),
                SettingsListItemWidget(
                  icon: Icons.data_usage,
                  title: 'Data Usage',
                  subtitle: 'Manage offline data preferences',
                  onTap: () => _showDataUsageSettings(),
                ),
                SettingsListItemWidget(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Learn how we handle your data',
                  onTap: () => _openPrivacyPolicy(),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Developer Tools Section
            SettingsSectionWidget(
              title: 'Developer Tools',
              children: [
                SettingsListItemWidget(
                  icon: Icons.image,
                  title: 'Gerenciador de Ícones',
                  subtitle: 'Visualizar e testar ícones do clima',
                  onTap: () {
                    Navigator.pushNamed(context, '/icon-manager');
                  },
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            SettingsSectionWidget(
              title: 'About',
              children: [
                SettingsListItemWidget(
                  icon: Icons.info,
                  title: 'App Version',
                  subtitle: _appVersion,
                ),
                SettingsListItemWidget(
                  icon: Icons.star_rate,
                  title: 'Rate App',
                  subtitle: 'Share your feedback',
                  onTap: () => _rateApp(),
                ),
                SettingsListItemWidget(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help with the app',
                  onTap: () => _openHelpSupport(),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showTemperatureUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Temperature Unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Celsius (°C)'),
                value: 'Celsius',
                groupValue: _temperatureUnit,
                onChanged: (value) {
                  setState(() {
                    _temperatureUnit = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Fahrenheit (°F)'),
                value: 'Fahrenheit',
                groupValue: _temperatureUnit,
                onChanged: (value) {
                  setState(() {
                    _temperatureUnit = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWindSpeedUnitDialog() {
    // Implementation for wind speed unit selection
  }

  void _showPressureUnitDialog() {
    // Implementation for pressure unit selection
  }

  void _navigateToCitySelection() {
    // Navigate to city selection screen
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
              'This will remove all cached weather data. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showDataUsageSettings() {
    // Implementation for data usage settings
  }

  void _openPrivacyPolicy() {
    // Implementation for opening privacy policy
  }

  void _rateApp() {
    // Implementation for rating the app
  }

  void _openHelpSupport() {
    // Implementation for help and support
  }
}
