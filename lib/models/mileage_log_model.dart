import 'package:cloud_firestore/cloud_firestore.dart';

class MileageLog {
  final String? id;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceMiles;

  MileageLog({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceMiles,
  });

  // Convert a MileageLog object into a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'distanceMiles': distanceMiles,
    };
  }
}