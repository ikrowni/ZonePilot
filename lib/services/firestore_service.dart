import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // THIS LINE IS NOW CORRECT
import 'package:image_picker/image_picker.dart';
import '../models/expense_model.dart';
import '../models/job_model.dart';
import '../models/mileage_log_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Stream<List<Job>> getJobsStream() {
    if (_user == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(_user.uid)
        .collection('jobs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<void> addJob(Job job) async {
    if (_user == null) return;
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('jobs')
        .add(job.toFirestore());
  }

  Future<void> addMileageLog(MileageLog log) async {
    if (_user == null) return;
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('mileage_logs')
        .add(log.toFirestore());
  }

  Stream<List<Expense>> getExpensesStream() {
    if (_user == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_user.uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }

  Future<void> addExpense(Expense expense) async {
    if (_user == null) return;
    await _db
        .collection('users')
        .doc(_user.uid)
        .collection('expenses')
        .add(expense.toFirestore());
  }
  
  Future<String?> uploadReceipt(XFile image) async {
    if (_user == null) return null;
    try {
      final filePath = 'receipts/${_user.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = _storage.ref().child(filePath);
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading receipt: $e');
      return null;
    }
  }

  Future<List<Job>> getJobsForTimeRange(DateTime start, DateTime end) async {
    if (_user == null) {
      return [];
    }
    final snapshot = await _db
        .collection('users')
        .doc(_user.uid)
        .collection('jobs')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThanOrEqualTo: end)
        .get();

    return snapshot.docs
        .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }
}