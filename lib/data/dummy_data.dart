import '../models/job_model.dart';

final List<Job> dummyJobs = [
  // Accepted Jobs
  Job(
    serviceName: 'DoorDash',
    serviceType: Service.doordash,
    timestamp: DateTime(2025, 8, 3, 17, 31),
    pay: 9.01,
    durationMinutes: 10,
    distanceMiles: 4.7,
    status: JobStatus.accepted,
    baseFare: 3.75,
    tip: 5.26,
    filtersFailedCount: 0,
  ),
  Job(
    serviceName: 'DoorDash',
    serviceType: Service.doordash,
    timestamp: DateTime(2025, 8, 1, 16, 56),
    pay: 4.00,
    durationMinutes: 8,
    distanceMiles: 2.9,
    status: JobStatus.accepted,
    filtersFailedCount: 0,
  ),
  Job(
    serviceName: 'Uber Delivery',
    serviceType: Service.uber,
    timestamp: DateTime(2025, 8, 1, 18, 46),
    pay: 9.55,
    durationMinutes: 12,
    distanceMiles: 6.8,
    status: JobStatus.accepted,
    filtersFailedCount: 0,
  ),

  // Rejected Jobs
  Job(
    serviceName: 'UberX',
    serviceType: Service.uber,
    timestamp: DateTime(2025, 8, 3, 18, 30),
    pay: 6.54,
    durationMinutes: 23,
    distanceMiles: 8.1,
    status: JobStatus.rejected,
    filtersFailedCount: 2,
  ),
  Job(
    serviceName: 'Uber Delivery',
    serviceType: Service.uber,
    timestamp: DateTime(2025, 8, 3, 18, 19),
    pay: 9.03,
    durationMinutes: 18,
    distanceMiles: 12.2,
    status: JobStatus.rejected,
    filtersFailedCount: 3,
  ),

  // Other/Dismissed Jobs
  Job(
    serviceName: 'Uber Delivery',
    serviceType: Service.uber,
    timestamp: DateTime(2025, 8, 3, 18, 10),
    pay: 19.17,
    durationMinutes: 40,
    distanceMiles: 34.0,
    status: JobStatus.dismissed,
    filtersFailedCount: 2,
  ),
  Job(
    serviceName: 'UberX',
    serviceType: Service.uber,
    timestamp: DateTime(2025, 8, 1, 18, 45),
    pay: 6.35,
    durationMinutes: 22,
    distanceMiles: 12.9,
    status: JobStatus.dismissed,
    filtersFailedCount: 4,
  ),
];