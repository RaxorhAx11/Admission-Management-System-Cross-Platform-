
class CourseModel {
  final String courseId;
  final String courseName;
  final String duration;
  final String fees;
  final String eligibility;
  final int seats;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.duration,
    required this.fees,
    required this.eligibility,
    required this.seats,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      courseId: map['courseId'] as String? ?? '',
      courseName: map['courseName'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      fees: map['fees'] as String? ?? '',
      eligibility: map['eligibility'] as String? ?? '',
      seats: (map['seats'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'duration': duration,
      'fees': fees,
      'eligibility': eligibility,
      'seats': seats,
    };
  }
}
