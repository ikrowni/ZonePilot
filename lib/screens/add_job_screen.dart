import 'package:flutter/material.dart';
import 'package:zone_pilot/models/job_model.dart';
import 'package:zone_pilot/services/firestore_service.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Form fields
  String _serviceName = 'DoorDash';
  double _pay = 0.0;
  int _durationMinutes = 0;
  double _distanceMiles = 0.0;
  JobStatus _status = JobStatus.accepted;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newJob = Job(
        serviceName: _serviceName,
        serviceType: _serviceName == 'Uber' ? Service.uber : Service.doordash,
        timestamp: DateTime.now(),
        pay: _pay,
        durationMinutes: _durationMinutes,
        distanceMiles: _distanceMiles,
        status: _status,
      );

      await _firestoreService.addJob(newJob);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Job'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _serviceName,
                items: ['DoorDash', 'Uber', 'Uber Delivery', 'UberX']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _serviceName = value ?? 'DoorDash';
                  });
                },
                decoration: const InputDecoration(labelText: 'Service'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Total Pay (\$)', prefixText: '\$'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter pay.' : null,
                onSaved: (value) => _pay = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter duration.' : null,
                onSaved: (value) => _durationMinutes = int.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Distance (miles)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter distance.' : null,
                onSaved: (value) => _distanceMiles = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<JobStatus>(
                value: _status,
                items: JobStatus.values
                    .map((status) => DropdownMenuItem(value: status, child: Text(status.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value ?? JobStatus.accepted;
                  });
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                child: const Text('Save Job'),
              )
            ],
          ),
        ),
      ),
    );
  }
}