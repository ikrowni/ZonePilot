import 'dart:math'; // Import for Random
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/job_history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTestJob() {
    final random = Random();
    // Create a small random offset to make each route unique
    final latOffset = (random.nextDouble() - 0.5) * 0.1;
    final lonOffset = (random.nextDouble() - 0.5) * 0.1;

    final testJob = Job(
      serviceName: 'DoorDash',
      serviceType: Service.doordash,
      timestamp: DateTime.now(),
      pay: 10 + random.nextDouble() * 15, // Random pay between 10-25
      durationMinutes: 15 + random.nextInt(30), // Random duration
      distanceMiles: 3 + random.nextDouble() * 10, // Random distance
      status: JobStatus.accepted,
      baseFare: 6.50,
      tip: 6.00,
      filtersFailedCount: 0,
      // UPDATED: Route data with random offsets
      routePoints: [
        GeoPoint(34.073 + latOffset, -81.335 + lonOffset), // Start
        GeoPoint(34.048 + latOffset, -81.245 + lonOffset), // Middle
        GeoPoint(34.000 + latOffset, -81.034 + lonOffset), // End
      ],
    );
    _firestoreService.addJob(testJob);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randomized test job added!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Test Job',
            onPressed: _addTestJob,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Zone Pilot',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          tabs: const [
            Tab(text: 'Accepted'),
            Tab(text: 'Rejected'),
            Tab(text: 'Other'),
          ],
        ),
      ),
      body: StreamBuilder<List<Job>>(
        stream: _firestoreService.getJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No job history found.',
                    style: TextStyle(color: AppColors.secondaryText)));
          }

          final allJobs = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildJobsList(allJobs, JobStatus.accepted),
              _buildJobsList(allJobs, JobStatus.rejected),
              _buildJobsList(allJobs, JobStatus.dismissed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobsList(List<Job> allJobs, JobStatus status) {
    final filteredJobs =
        allJobs.where((job) => job.status == status).toList();

    if (filteredJobs.isEmpty) {
      return const Center(
        child: Text(
          'No jobs found for this category.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredJobs.length,
      separatorBuilder: (context, index) {
        return const Divider(color: AppColors.secondaryText, height: 1);
      },
      itemBuilder: (context, index) {
        final currentJob = filteredJobs[index];
        final previousJob = index > 0 ? filteredJobs[index - 1] : null;

        final bool isNewDay = previousJob == null ||
            currentJob.timestamp.day != previousJob.timestamp.day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNewDay)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  DateFormat.yMMMMd('en_US').format(currentJob.timestamp),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            JobHistoryCard(job: filteredJobs[index]),
          ],
        );
      },
    );
  }
}
