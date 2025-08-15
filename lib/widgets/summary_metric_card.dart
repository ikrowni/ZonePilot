import 'package:flutter/material.dart';
import '../main.dart';

class SummaryMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String rate;

  const SummaryMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rate,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}