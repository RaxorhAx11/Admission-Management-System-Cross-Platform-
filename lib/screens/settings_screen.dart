import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/constants/app_routes.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/providers/theme_provider.dart';
import 'package:admission_management/widgets/app_card.dart';

/// Settings: Light/Dark theme toggle, logout, app version.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark theme',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        Consumer<ThemeProvider>(
                          builder: (_, themeProvider, __) {
                            return Switch(
                              value: themeProvider.isDark,
                              onChanged: (value) => themeProvider.setDark(value),
                              activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          navigator.pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Version $appVersion',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
