import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:admission_management/core/constants/app_constants.dart';


class ApplicationModel {
  final String applicationId;
  final String studentId;
  final String courseId;
  final Map<String, dynamic> additionalDetails;
  final Map<String, String> documentUrls;
  final String status; 
  final String remarks;
  final DateTime appliedDate;

  ApplicationModel({
    required this.applicationId,
    required this.studentId,
    required this.courseId,
    required this.additionalDetails,
    required this.documentUrls,
    required this.status,
    required this.remarks,
    required this.appliedDate,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    final docUrls = map[AppConstants.documentUrls] as Map<String, dynamic>?;
    final urls = <String, String>{};
    if (docUrls != null) {
      docUrls.forEach((k, v) {
        if (v != null) urls[k] = v.toString();
      });
    }
    final ts = map[AppConstants.appliedDate];
    DateTime date = DateTime.now();
    if (ts != null) {
      if (ts is Timestamp) {
        date = ts.toDate();
      } else if (ts is DateTime) {
        date = ts;
      }
    }
    return ApplicationModel(
      applicationId: map[AppConstants.applicationId] as String? ?? '',
      studentId: map[AppConstants.studentId] as String? ?? '',
      courseId: map[AppConstants.courseIdKey] as String? ?? '',
      additionalDetails: Map<String, dynamic>.from(map[AppConstants.additionalDetails] as Map? ?? {}),
      documentUrls: urls,
      status: map[AppConstants.status] as String? ?? AppConstants.statusPending,
      remarks: map[AppConstants.remarks] as String? ?? '',
      appliedDate: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.applicationId: applicationId,
      AppConstants.studentId: studentId,
      AppConstants.courseIdKey: courseId,
      AppConstants.additionalDetails: additionalDetails,
      AppConstants.documentUrls: documentUrls,
      AppConstants.status: status,
      AppConstants.remarks: remarks,
      AppConstants.appliedDate: Timestamp.fromDate(appliedDate),
    };
  }
}
