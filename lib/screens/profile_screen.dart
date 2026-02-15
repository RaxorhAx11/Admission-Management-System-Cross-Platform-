import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/constants/app_routes.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/widgets/app_card.dart';

/// Profile: view name, email, role; edit name; save to Firestore; logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          if (!_isEditing && _nameController.text != user.name) {
            _nameController.text = user.name;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Your name',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_saving)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              TextButton(
                                onPressed: () async {
                                  final name = _nameController.text.trim();
                                  if (name.isEmpty) return;
                                  final messenger = ScaffoldMessenger.of(context);
                                  setState(() => _saving = true);
                                  final ok = await auth.updateUserName(name);
                                  setState(() {
                                    _saving = false;
                                    _isEditing = !ok;
                                  });
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            ok ? 'Name updated' : 'Failed to update'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _nameController.text = user.name;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _isEditing = true),
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await auth.signOut();
                    if (mounted) {
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
              ],
            ),
          );
        },
      ),
    );
  }
}
