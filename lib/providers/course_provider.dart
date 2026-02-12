import 'package:flutter/foundation.dart';

import 'package:admission_management/models/course_model.dart';
import 'package:admission_management/services/firestore_service.dart';

/// Courses list and CRUD for admin. Students use this to view courses.
class CourseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch courses once (e.g. for course list screen).
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _courses = await _firestoreService.getCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream courses (optional, for real-time updates).
  Stream<List<CourseModel>> get coursesStream => _firestoreService.getCoursesStream();

  Future<CourseModel?> getCourseById(String courseId) async {
    return _firestoreService.getCourseById(courseId);
  }

  /// Admin: Add course.
  Future<bool> addCourse(CourseModel course) async {
    try {
      await _firestoreService.addCourse(course);
      await fetchCourses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Admin: Edit course.
  Future<bool> updateCourse(CourseModel course) async {
    try {
      await _firestoreService.updateCourse(course);
      await fetchCourses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Admin: Delete course.
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _firestoreService.deleteCourse(courseId);
      await fetchCourses();
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
