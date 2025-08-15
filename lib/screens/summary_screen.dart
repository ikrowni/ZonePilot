import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zone_pilot/models/summary_data_model.dart';
import 'package:zone_pilot/services/firestore_service.dart';
import '../main.dart';
import '../widgets/summary_metric_card.dart';

enum TimeFilter { today, last24h, last7days }

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  final List<bool> _isSelected = [true, false, false];
  TimeFilter _filter = TimeFilter.today;
  SummaryData? _summaryData;
  bool _isLoading = true;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {}; // NEW: Set to hold map markers
  GoogleMapController? _mapController;
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(34.0007, -81.0348),
    zoom: 9,
  );

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

  Future<void> _fetchSummaryData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    DateTime now = DateTime.now();
    DateTime startTime;

    switch (_filter) {
      case TimeFilter.today:
        startTime = DateTime(now.year, now.month, now.day);
        break;
      case TimeFilter.last24h:
        startTime = now.subtract(const Duration(hours: 24));
        break;
      case TimeFilter.last7days:
        startTime = now.subtract(const Duration(days: 7));
        break;
    }

    final jobs = await _firestoreService.getJobsForTimeRange(startTime, now);
    
    double totalEarnings = 0;
    double totalDistance = 0;
    int totalMinutes = 0;
    final Set<Polyline> newPolylines = {};
    final Set<Marker> newMarkers = {}; // NEW: Set for new markers
    List<LatLng> allPoints = [];

    for (int i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      totalEarnings += job.pay;
      totalDistance += job.distanceMiles;
      totalMinutes += job.durationMinutes;

      if (job.routePoints.isNotEmpty) {
        final points = job.routePoints
            .map((geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude))
            .toList();
        
        allPoints.addAll(points);

        newPolylines.add(Polyline(
          polylineId: PolylineId('job_route_$i'),
          points: points,
          color: AppColors.primaryOrange,
          width: 4,
        ));

        // NEW: Add start and end markers for each route
        newMarkers.add(Marker(
          markerId: MarkerId('start_marker_$i'),
          position: points.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        newMarkers.add(Marker(
          markerId: MarkerId('end_marker_$i'),
          position: points.last,
        ));
      }
    }

    if (_mapController != null && allPoints.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFromLatLngList(allPoints), 50),
      );
    }

    if (mounted) {
      setState(() {
        _summaryData = SummaryData(
          rideCount: jobs.length,
          totalEarnings: totalEarnings,
          totalDistance: totalDistance,
          totalDurationMinutes: totalMinutes,
        );
        _polylines = newPolylines;
        _markers = newMarkers; // NEW: Update markers state
        _isLoading = false;
      });
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  void _shareSummary() async {
    final Uint8List? image = await _screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/summary.png').create();
    await imagePath.writeAsBytes(image);

    await Share.shareXFiles([XFile(imagePath.path)], text: 'Here is my earnings summary!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        centerTitle: true,
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ToggleButtons(
                  isSelected: _isSelected,
                  onPressed: (index) {
                    if (mounted) {
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == index;
                        }
                        _filter = TimeFilter.values[index];
                        _fetchSummaryData();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(30.0),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Today')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Last 24h')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Last 7 days')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: GoogleMap(
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (controller) => _mapController = controller,
                    polylines: _polylines,
                    markers: _markers, // NEW: Add markers to the map
                    // REMOVED gesture disabling to make map interactive
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${DateFormat.yMMMMd().format(DateTime.now())} • ${_summaryData?.rideCount ?? 0} rides',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                _buildMetricsGrid(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Share', style: TextStyle(fontSize: 16)),
                  onPressed: _shareSummary,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final data = _summaryData ?? SummaryData();
    return Column(
      children: [
        Row(
          children: [
            SummaryMetricCard(
              label: 'Total Earnings',
              value: '\$${data.totalEarnings.toStringAsFixed(2)}',
              rate: '+ tips',
            ),
            const SizedBox(width: 16),
            SummaryMetricCard(
              label: 'Booked',
              value: '${data.totalDurationMinutes}m',
              rate: '\$${data.earningsPerHour.toStringAsFixed(2)} / h',
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            SummaryMetricCard(
              label: 'Booked Distance',
              value: '${data.totalDistance.toStringAsFixed(1)} mi',
              rate: '\$${data.earningsPerMile.toStringAsFixed(2)} / mi',
            ),
            const SizedBox(width: 16),
            const SummaryMetricCard(
              label: 'Online',
              value: '0h',
              rate: '\$ 0.00 / h',
            ),
          ],
        ),
      ],
    );
  }
}
