import 'package:flutter/material.dart';

import 'package:admission_management/core/constants/app_routes.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/models/course_model.dart';
import 'package:admission_management/widgets/app_card.dart';

/// Student: View course details and apply for admission.
class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(course.courseName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book_outlined,
                          color: AppTheme.primaryColor, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          course.courseName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Duration', value: course.duration),
                  _DetailRow(label: 'Fees', value: '₹${course.fees}'),
                  _DetailRow(label: 'Eligibility', value: course.eligibility),
                  _DetailRow(label: 'Seats', value: '${course.seats}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.admissionForm,
                  arguments: course,
                );
              },
              icon: const Icon(Icons.edit_document),
              label: const Text('Apply for Admission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
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
            width: 100,
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
