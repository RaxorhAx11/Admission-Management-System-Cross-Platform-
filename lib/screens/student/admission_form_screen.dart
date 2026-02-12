import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/models/application_model.dart';
import 'package:admission_management/models/course_model.dart';
import 'package:admission_management/providers/application_provider.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/widgets/app_card.dart';

/// Student: Fill admission form with additional details (parent, qualification, etc.).
class AdmissionFormScreen extends StatefulWidget {
  final CourseModel course;

  const AdmissionFormScreen({super.key, required this.course});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parentNameController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _lastQualificationController = TextEditingController();
  final _passingYearController = TextEditingController();
  final _percentageController = TextEditingController();
  String? _selectedCategory;

  static const List<String> _categoryOptions = ['GC', 'OBCs', 'STs', 'SCs'];

  @override
  void dispose() {
    _parentNameController.dispose();
    _parentContactController.dispose();
    _lastQualificationController.dispose();
    _passingYearController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final studentId = auth.user?.uid ?? '';
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not logged in')));
      return;
    }

    final applicationId = const Uuid().v4();
    final appProvider = context.read<ApplicationProvider>();
    appProvider.clearError();

    final additionalDetails = {
      'parentName': _parentNameController.text.trim(),
      'parentContact': _parentContactController.text.trim(),
      'lastQualification': _lastQualificationController.text.trim(),
      'passingYear': _passingYearController.text.trim(),
      'percentageOrCgpa': _percentageController.text.trim(),
      'category': _selectedCategory ?? '',
    };

    final application = ApplicationModel(
      applicationId: applicationId,
      studentId: studentId,
      courseId: widget.course.courseId,
      additionalDetails: additionalDetails,
      documentUrls: {},
      status: AppConstants.statusPending,
      remarks: '',
      appliedDate: DateTime.now(),
    );

    final success = await appProvider.submitApplication(application);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProvider.error ?? 'Submission failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text('Apply: ${widget.course.courseName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Parent / Guardian Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _parentContactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Parent Contact Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastQualificationController,
                      decoration: const InputDecoration(
                        labelText: 'Last Qualification',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passingYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Passing Year',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _percentageController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Percentage / CGPA',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      hint: const Text('Select category'),
                      items: _categoryOptions
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a category' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer<ApplicationProvider>(
                builder: (_, appProvider, __) {
                  return ElevatedButton.icon(
                    onPressed: appProvider.isLoading ? null : _submit,
                    icon: appProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(appProvider.isLoading ? 'Submitting...' : 'Submit Application'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
