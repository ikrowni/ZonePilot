import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import '../models/job_model.dart';

class OfferDetailsScreen extends StatelessWidget {
  final Job job;

  const OfferDetailsScreen({super.key, required this.job});

  // A helper widget to create consistent detail rows
  Widget _buildDetailRow(String label, String value, {bool isSubtle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSubtle ? AppColors.secondaryText : AppColors.primaryText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Details'),
        centerTitle: false, // Aligns title to the left
      ),
      body: ListView(
        children: [
          // Map View
          const SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(34.073, -81.335), // Centered on Chapin, SC
                zoom: 12,
              ),
              mapType: MapType.normal,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Total Fare', '\$${job.pay.toStringAsFixed(2)}'),
                const Divider(color: AppColors.secondaryText),
                _buildDetailRow('Base Fare', '\$${job.baseFare?.toStringAsFixed(2) ?? '0.00'}', isSubtle: true),
                _buildDetailRow('Tip', '\$${job.tip?.toStringAsFixed(2) ?? '0.00'}', isSubtle: true),
                const SizedBox(height: 24),

                _buildDetailRow('Ride Length', '${job.distanceMiles.toStringAsFixed(1)} mi'),
                const Divider(color: AppColors.secondaryText),
                _buildDetailRow('Ride Duration', '${job.durationMinutes} min'),
                const Divider(color: AppColors.secondaryText),

                _buildDetailRow('\$/Hour', '\$${job.dollarsPerHour.toStringAsFixed(2)}'),
                const Divider(color: AppColors.secondaryText),
                _buildDetailRow('\$/Mile', '\$${job.dollarsPerMile.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}