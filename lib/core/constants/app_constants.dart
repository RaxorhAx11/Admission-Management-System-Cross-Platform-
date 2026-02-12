
class AppConstants {
  
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String applicationsCollection = 'applications';

  // User fields
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';

  // Roles
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Course fields
  static const String courseId = 'courseId';
  static const String courseName = 'courseName';
  static const String duration = 'duration';
  static const String fees = 'fees';
  static const String eligibility = 'eligibility';
  static const String seats = 'seats';

  // Application fields
  static const String applicationId = 'applicationId';
  static const String studentId = 'studentId';
  static const String courseIdKey = 'courseId';
  static const String additionalDetails = 'additionalDetails';
  static const String documentUrls = 'documentUrls';
  static const String status = 'status';
  static const String remarks = 'remarks';
  static const String appliedDate = 'appliedDate';

  // Application status values
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Storage paths for uploaded documents
  static const String storageApplications = 'applications';
  static const String photoKey = 'photo';
  static const String idProofKey = 'idProof';
  static const String marksheetKey = 'marksheet';
}
