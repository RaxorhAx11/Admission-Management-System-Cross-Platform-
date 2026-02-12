import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/models/course_model.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/providers/course_provider.dart';
import 'package:admission_management/screens/student/course_detail_screen.dart';
import 'package:admission_management/widgets/app_card.dart';
import 'package:admission_management/widgets/loading_widget.dart';

/// Student: View available courses. Tap to see course details.
class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Available Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Applications',
            onPressed: () {
              Navigator.of(context).pushNamed('/student/applications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (_, courseProvider, __) {
          if (courseProvider.isLoading && courseProvider.courses.isEmpty) {
            return const LoadingWidget();
          }
          if (courseProvider.error != null && courseProvider.courses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(courseProvider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => courseProvider.fetchCourses(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final list = courseProvider.courses;
          if (list.isEmpty) {
            return const Center(child: Text('No courses available yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final course = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: course),
                      ),
                    );
                  },
                  child: _CourseTile(course: course),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final CourseModel course;

  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.menu_book_outlined, color: AppTheme.primaryColor, size: 40),
        const SizedBox(width: 16),
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
              const SizedBox(height: 4),
              Text(
                '${course.duration} • ₹${course.fees}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}
