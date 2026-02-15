import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/core/constants/app_routes.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/models/application_model.dart';
import 'package:admission_management/models/course_model.dart';
import 'package:admission_management/providers/application_provider.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/providers/course_provider.dart';
import 'package:admission_management/widgets/app_card.dart';
import 'package:admission_management/widgets/loading_widget.dart';

/// Admin dashboard: total/pending/approved/rejected counts, course management, application management.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchAllApplications();
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Applications', icon: Icon(Icons.list_alt)),
            Tab(text: 'Courses', icon: Icon(Icons.menu_book)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ApplicationsTab(),
          _CoursesTab(),
        ],
      ),
    );
  }
}

class _ApplicationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (_, appProvider, __) {
        if (appProvider.isLoading && appProvider.applications.isEmpty) {
          return const LoadingWidget();
        }
        final list = appProvider.applications;
        return RefreshIndicator(
          onRefresh: () => appProvider.fetchAllApplications(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Application Stats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total',
                              value: '${appProvider.totalCount}',
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Pending',
                              value: '${appProvider.pendingCount}',
                              color: AppTheme.pendingColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Approved',
                              value: '${appProvider.approvedCount}',
                              color: AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Rejected',
                              value: '${appProvider.rejectedCount}',
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (list.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No applications yet.')),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final app = list[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: AppCard(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.applicationDetail,
                              arguments: app.applicationId,
                            );
                          },
                          child: _ApplicationTile(application: app),
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationTile({required this.application});

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
    return Row(
      children: [
        const Icon(Icons.description_outlined, color: AppTheme.primaryColor, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${application.applicationId.substring(0, 8)}...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              Text(
                'Course: ${application.courseId} • ${application.status}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            application.status.toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}

class _CoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (_, courseProvider, __) {
        if (courseProvider.isLoading && courseProvider.courses.isEmpty) {
          return const LoadingWidget();
        }
        final list = courseProvider.courses;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Course Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditCourseDialog(context, courseProvider, null),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Course'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No courses. Add one above.'),
              ))
            else
              ...list.map((course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.courseName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                                Text(
                                  '${course.duration} • ₹${course.fees} • ${course.seats} seats',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showAddEditCourseDialog(context, courseProvider, course),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDeleteCourse(context, courseProvider, course),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showAddEditCourseDialog(
    BuildContext context,
    CourseProvider courseProvider,
    CourseModel? existing,
  ) {
    final courseIdController = TextEditingController(
      text: existing?.courseId ?? 'course_${DateTime.now().millisecondsSinceEpoch}',
    );
    final nameController = TextEditingController(text: existing?.courseName ?? '');
    final durationController = TextEditingController(text: existing?.duration ?? '');
    final feesController = TextEditingController(text: existing?.fees ?? '');
    final eligibilityController = TextEditingController(text: existing?.eligibility ?? '');
    final seatsController = TextEditingController(
      text: existing != null ? '${existing.seats}' : '',
    );
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Course' : 'Add Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit) ...[
                TextField(
                  controller: courseIdController,
                  decoration: const InputDecoration(labelText: 'Course ID (e.g. BCA-2024)'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (e.g. 3 years)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fees'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: eligibilityController,
                decoration: const InputDecoration(labelText: 'Eligibility'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Seats'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = isEdit ? existing.courseId : courseIdController.text.trim();
              final course = CourseModel(
                courseId: id.isEmpty ? 'course_${DateTime.now().millisecondsSinceEpoch}' : id,
                courseName: nameController.text.trim(),
                duration: durationController.text.trim(),
                fees: feesController.text.trim(),
                eligibility: eligibilityController.text.trim(),
                seats: int.tryParse(seatsController.text.trim()) ?? 0,
              );
              if (isEdit) {
                await courseProvider.updateCourse(course);
              } else {
                await courseProvider.addCourse(course);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCourse(
    BuildContext context,
    CourseProvider courseProvider,
    CourseModel course,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${course.courseName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () async {
              await courseProvider.deleteCourse(course.courseId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
