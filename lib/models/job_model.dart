import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus { accepted, rejected, dismissed }
enum Service { uber, doordash }

class Job {
  final String serviceName;
  final Service serviceType;
  final DateTime timestamp;
  final double pay;
  final int durationMinutes;
  final double distanceMiles;
  final JobStatus status;
  final double? baseFare;
  final double? tip;
  final int? filtersFailedCount;
  final List<GeoPoint> routePoints; // NEW: To store the job's route

  Job({
    required this.serviceName,
    required this.serviceType,
    required this.timestamp,
    required this.pay,
    required this.durationMinutes,
    required this.distanceMiles,
    required this.status,
    this.baseFare,
    this.tip,
    this.filtersFailedCount,
    this.routePoints = const [], // Default to an empty list
  });

  factory Job.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    // Convert the list from Firestore to a List<GeoPoint>
    final routeData = data['routePoints'] as List<dynamic>? ?? [];
    final routePoints = routeData.map((point) => point as GeoPoint).toList();

    return Job(
      serviceName: data['serviceName'],
      serviceType: Service.values.byName(data['serviceType']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      pay: data['pay'],
      durationMinutes: data['durationMinutes'],
      distanceMiles: data['distanceMiles'],
      status: JobStatus.values.byName(data['status']),
      baseFare: data['baseFare'],
      tip: data['tip'],
      filtersFailedCount: data['filtersFailedCount'],
      routePoints: routePoints,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'serviceName': serviceName,
      'serviceType': serviceType.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'pay': pay,
      'durationMinutes': durationMinutes,
      'distanceMiles': distanceMiles,
      'status': status.name,
      'baseFare': baseFare,
      'tip': tip,
      'filtersFailedCount': filtersFailedCount,
      'routePoints': routePoints,
    };
  }

  double get dollarsPerHour {
    if (durationMinutes == 0) return 0;
    return (pay / durationMinutes) * 60;
  }

  double get dollarsPerMile {
    if (distanceMiles == 0) return 0;
    return pay / distanceMiles;
  }
}