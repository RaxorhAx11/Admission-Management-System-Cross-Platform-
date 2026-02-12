import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/models/application_model.dart';
import 'package:admission_management/models/course_model.dart';
import 'package:admission_management/providers/application_provider.dart';
import 'package:admission_management/providers/course_provider.dart';
import 'package:admission_management/widgets/app_card.dart';
import 'package:admission_management/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

/// Admin: View student details, uploaded documents (from Firebase Storage URLs), approve/reject, add remarks.
class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  ApplicationModel? _application;
  CourseModel? _course;
  bool _loading = true;
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final appProvider = context.read<ApplicationProvider>();
    final courseProvider = context.read<CourseProvider>();
    final app = await appProvider.getApplicationById(widget.applicationId);
    if (app == null) {
      setState(() => _loading = false);
      return;
    }
    CourseModel? course;
    if (app.courseId.isNotEmpty) {
      course = await courseProvider.getCourseById(app.courseId);
    }
    setState(() {
      _application = app;
      _course = course;
      _remarksController.text = app.remarks;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String status) async {
    final app = _application;
    if (app == null) return;
    final remarks = _remarksController.text.trim();
    final appProvider = context.read<ApplicationProvider>();
    final ok = await appProvider.updateStatus(
      applicationId: app.applicationId,
      status: status,
      remarks: remarks.isEmpty ? (status == AppConstants.statusApproved ? 'Approved' : 'Rejected') : remarks,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application $status')),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProvider.error ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }
    final app = _application;
    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application')),
        body: const Center(child: Text('Application not found')),
      );
    }

    final details = app.additionalDetails;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text('Application #${app.applicationId.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.status.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _statusColor(app.status),
                        ),
                  ),
                  Text(
                    'Applied: ${DateFormat.yMMMd().format(app.appliedDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  if (_course != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Course: ${_course!.courseName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Parent / Guardian',
                    value: details['parentName']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Parent Contact',
                    value: details['parentContact']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Last Qualification',
                    value: details['lastQualification']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Passing Year',
                    value: details['passingYear']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Percentage / CGPA',
                    value: details['percentageOrCgpa']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Category',
                    value: details['category']?.toString() ?? '-',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploaded Documents (Firebase Storage)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (app.documentUrls[AppConstants.photoKey] != null)
                    _DocumentLink(
                      label: 'Photo',
                      url: app.documentUrls[AppConstants.photoKey]!,
                    ),
                  if (app.documentUrls[AppConstants.idProofKey] != null)
                    _DocumentLink(
                      label: 'ID Proof',
                      url: app.documentUrls[AppConstants.idProofKey]!,
                    ),
                  if (app.documentUrls[AppConstants.marksheetKey] != null)
                    _DocumentLink(
                      label: 'Marksheet',
                      url: app.documentUrls[AppConstants.marksheetKey]!,
                    ),
                  if (app.documentUrls.isEmpty)
                    Text(
                      'No documents',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Remarks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add remarks (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (app.status == AppConstants.statusPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(AppConstants.statusApproved),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(AppConstants.statusRejected),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _DocumentLink extends StatelessWidget {
  final String label;
  final String url;

  const _DocumentLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.link, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open: $label')),
                  );
                }
              }
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
