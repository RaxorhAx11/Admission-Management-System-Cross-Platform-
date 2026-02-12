import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/models/application_model.dart';
import 'package:admission_management/models/course_model.dart';

/// Firestore CRUD for courses and applications. Keeps logic simple and readable.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------- Courses ----------

  Stream<List<CourseModel>> getCoursesStream() {
    return _firestore
        .collection(AppConstants.coursesCollection)
        .orderBy(AppConstants.courseName)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CourseModel.fromMap(d.data())).toList());
  }

  Future<List<CourseModel>> getCourses() async {
    final snap = await _firestore
        .collection(AppConstants.coursesCollection)
        .orderBy(AppConstants.courseName)
        .get();
    return snap.docs.map((d) => CourseModel.fromMap(d.data())).toList();
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    final snap = await _firestore
        .collection(AppConstants.coursesCollection)
        .where(AppConstants.courseId, isEqualTo: courseId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return CourseModel.fromMap(snap.docs.first.data());
  }

  /// Admin: Add course. courseId should be unique (e.g. from uuid).
  Future<void> addCourse(CourseModel course) async {
    await _firestore.collection(AppConstants.coursesCollection).doc(course.courseId).set(course.toMap());
  }

  /// Admin: Edit course.
  Future<void> updateCourse(CourseModel course) async {
    await _firestore.collection(AppConstants.coursesCollection).doc(course.courseId).update(course.toMap());
  }

  /// Admin: Delete course.
  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection(AppConstants.coursesCollection).doc(courseId).delete();
  }

  // ---------- Applications ----------

  /// Student: Submit new application. applicationId should be unique.
  Future<void> submitApplication(ApplicationModel application) async {
    await _firestore
        .collection(AppConstants.applicationsCollection)
        .doc(application.applicationId)
        .set(application.toMap());
  }

  /// Student: Get applications for a student (stream for real-time updates).
  Stream<List<ApplicationModel>> getApplicationsForStudent(String studentId) {
    return _firestore
        .collection(AppConstants.applicationsCollection)
        .where(AppConstants.studentId, isEqualTo: studentId)
        .orderBy(AppConstants.appliedDate, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ApplicationModel.fromMap(d.data())).toList());
  }

  /// Student: Get applications for a student once (for fetch).
  Future<List<ApplicationModel>> getApplicationsForStudentOnce(String studentId) async {
    final snap = await _firestore
        .collection(AppConstants.applicationsCollection)
        .where(AppConstants.studentId, isEqualTo: studentId)
        .orderBy(AppConstants.appliedDate, descending: true)
        .get();
    return snap.docs.map((d) => ApplicationModel.fromMap(d.data())).toList();
  }

  /// Admin: Get all applications.
  Stream<List<ApplicationModel>> getAllApplicationsStream() {
    return _firestore
        .collection(AppConstants.applicationsCollection)
        .orderBy(AppConstants.appliedDate, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ApplicationModel.fromMap(d.data())).toList());
  }

  Future<List<ApplicationModel>> getAllApplications() async {
    final snap = await _firestore
        .collection(AppConstants.applicationsCollection)
        .orderBy(AppConstants.appliedDate, descending: true)
        .get();
    return snap.docs.map((d) => ApplicationModel.fromMap(d.data())).toList();
  }

  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    final doc = await _firestore
        .collection(AppConstants.applicationsCollection)
        .doc(applicationId)
        .get();
    if (!doc.exists) return null;
    return ApplicationModel.fromMap(doc.data()!);
  }

  /// Admin: Approve or reject application and add remarks.
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    required String remarks,
  }) async {
    await _firestore.collection(AppConstants.applicationsCollection).doc(applicationId).update({
      AppConstants.status: status,
      AppConstants.remarks: remarks,
    });
  }
}
