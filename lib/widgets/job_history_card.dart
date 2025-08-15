import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/job_model.dart';
import '../screens/offer_details_screen.dart';

class JobHistoryCard extends StatelessWidget {
  final Job job;

  const JobHistoryCard({super.key, required this.job});

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return 'Accepted';
      case JobStatus.rejected:
        return 'Declined';
      case JobStatus.dismissed:
        return 'Dismissed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final orangeTextStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.primaryOrange,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsScreen(job: job),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(job.serviceName, style: textTheme.titleMedium),
                Row(
                  children: [
                    Text(
                      DateFormat.jm().format(job.timestamp),
                      style: textTheme.bodyMedium,
                    ),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${job.pay.toStringAsFixed(2)} • ${job.durationMinutes} min • ${job.distanceMiles.toStringAsFixed(1)} mi',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(job.status),
                      style: textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${job.dollarsPerHour.toStringAsFixed(2)}/hr • \$${job.dollarsPerMile.toStringAsFixed(2)}/mi',
                      style: orangeTextStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (job.filtersFailedCount ?? 0) == 0
                          ? 'Filters passed'
                          : 'Filters failed: ${job.filtersFailedCount}',
                      style: textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}