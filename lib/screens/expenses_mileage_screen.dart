import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zone_pilot/models/expense_model.dart';
import 'package:zone_pilot/models/mileage_log_model.dart';
import 'package:zone_pilot/services/firestore_service.dart';

class ExpensesMileageScreen extends StatefulWidget {
  const ExpensesMileageScreen({super.key});

  @override
  State<ExpensesMileageScreen> createState() => _ExpensesMileageScreenState();
}

class _ExpensesMileageScreenState extends State<ExpensesMileageScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isTracking = false;
  double _totalDistanceMeters = 0.0;
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _startTime;

  double get _totalDistanceMiles => _totalDistanceMeters * 0.000621371;

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        }
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      }
      return false;
    } 
    return true;
  }

  void _toggleTracking() {
    if (_isTracking) {
      _stopTracking();
    } else {
      _startTracking();
    }
  }

  void _startTracking() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission || !mounted) return;

    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
      _totalDistanceMeters = 0.0;
    });

    Position? lastPosition;
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10)
    ).listen((Position position) {
      if (lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _totalDistanceMeters += distance;
          });
        }
      }
      lastPosition = position;
    });
  }

  void _stopTracking() {
    if (_startTime != null) {
      final log = MileageLog(
        startTime: _startTime!,
        endTime: DateTime.now(),
        distanceMiles: _totalDistanceMiles,
      );
      _firestoreService.addMileageLog(log);
    }
    
    _positionStreamSubscription?.cancel();
    if (mounted) {
      setState(() {
        _isTracking = false;
      });
    }
  }

  void _showAddExpenseDialog() {
    final formKey = GlobalKey<FormState>();
    String description = '';
    double amount = 0.0;
    XFile? receiptImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Add Expense'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Please enter a description.' : null,
                  onSaved: (value) => description = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount (\$)', prefixText: '\$'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter an amount.' : null,
                  onSaved: (value) => amount = double.tryParse(value!) ?? 0.0,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Upload Receipt'),
                  onPressed: () async {
                    receiptImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  String? imageUrl;
                  if (receiptImage != null) {
                    imageUrl = await _firestoreService.uploadReceipt(receiptImage!);
                  }
                  final newExpense = Expense(
                    description: description,
                    amount: amount,
                    date: DateTime.now(),
                    receiptImageUrl: imageUrl,
                  );
                  await _firestoreService.addExpense(newExpense);
                  
                  // ignore: use_build_context_synchronously
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & Mileage'),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('MILEAGE', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    '${_totalDistanceMiles.toStringAsFixed(2)} miles', 
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red.shade700 : Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('EXPENSES', style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: _firestoreService.getExpensesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No expenses added yet.'));
                }
                final expenses = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(expense.description),
                      subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}