import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/models/application_model.dart';
import 'package:admission_management/providers/application_provider.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/widgets/app_card.dart';
import 'package:admission_management/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

/// Student: View application status (Pending / Approved / Rejected) and admin remarks.
class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ApplicationProvider>().fetchApplicationsForStudent(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('My Applications')),
      body: Consumer<ApplicationProvider>(
        builder: (_, appProvider, __) {
          if (appProvider.isLoading && appProvider.applications.isEmpty) {
            return const LoadingWidget();
          }
          if (appProvider.error != null && appProvider.applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appProvider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final uid = context.read<AuthProvider>().user?.uid;
                        if (uid != null) appProvider.fetchApplicationsForStudent(uid);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final list = appProvider.applications;
          if (list.isEmpty) {
            return const Center(
              child: Text('You have not submitted any application yet.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final app = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: _ApplicationStatusTile(application: app),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicationStatusTile extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationStatusTile({required this.application});

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return AppTheme.successColor;
      case AppConstants.statusRejected:
        return AppTheme.errorColor;
      default:
        return AppTheme.pendingColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(application.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Application #${application.applicationId.substring(0, 8)}...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Course ID: ${application.courseId}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          'Applied: ${DateFormat.yMMMd().format(application.appliedDate)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        if (application.remarks.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Remarks: ${application.remarks}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ],
    );
  }
}
