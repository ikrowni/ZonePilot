class SummaryData {
  final int rideCount;
  final double totalEarnings;
  final double totalDistance;
  final int totalDurationMinutes;

  SummaryData({
    this.rideCount = 0,
    this.totalEarnings = 0.0,
    this.totalDistance = 0.0,
    this.totalDurationMinutes = 0,
  });

  // Calculated properties
  double get earningsPerHour {
    if (totalDurationMinutes == 0) return 0.0;
    return (totalEarnings / totalDurationMinutes) * 60;
  }

  double get earningsPerMile {
    if (totalDistance == 0) return 0.0;
    return totalEarnings / totalDistance;
  }
}