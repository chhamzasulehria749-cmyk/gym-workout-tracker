import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Dark theme is enabled'
                        : 'Light theme is enabled',
                  ),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.primary,
              ),
              title: const Text(
                'Workout Notifications',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Manage workout reminders'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings coming soon.'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'About',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primary,
              ),
              title: const Text(
                'About Gym Tracker',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Train • Track • Improve'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Gym Tracker',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppTheme.primary,
                    size: 35,
                  ),
                  children: const [
                    Text(
                      'A simple workout tracking application built with Flutter.',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
