import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/models/application_model.dart';
import 'package:admission_management/services/firestore_service.dart';

/// Applications: submit (student), list (student/admin), update status (admin).
class ApplicationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _error;

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCount => _applications.length;
  int get pendingCount => _applications.where((a) => a.status == AppConstants.statusPending).length;
  int get approvedCount => _applications.where((a) => a.status == AppConstants.statusApproved).length;
  int get rejectedCount => _applications.where((a) => a.status == AppConstants.statusRejected).length;

  /// Student: Submit new application.
  Future<bool> submitApplication(ApplicationModel application) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Add a timeout so UI is not stuck forever if Firestore hangs.
      await _firestoreService
          .submitApplication(application)
          .timeout(const Duration(seconds: 20));
      _isLoading = false;
      notifyListeners();
      return true;
    } on TimeoutException {
      _error = 'Submitting application is taking too long. Please check your connection and try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Student: Fetch applications for a student.
  Future<void> fetchApplicationsForStudent(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _applications = await _firestoreService.getApplicationsForStudentOnce(studentId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Admin: Fetch all applications.
  Future<void> fetchAllApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _applications = await _firestoreService.getAllApplications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ApplicationModel>> get allApplicationsStream =>
      _firestoreService.getAllApplicationsStream();

  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    return _firestoreService.getApplicationById(applicationId);
  }

  /// Admin: Approve or reject and add remarks.
  Future<bool> updateStatus({
    required String applicationId,
    required String status,
    required String remarks,
  }) async {
    try {
      await _firestoreService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
        remarks: remarks,
      );
      await fetchAllApplications();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
