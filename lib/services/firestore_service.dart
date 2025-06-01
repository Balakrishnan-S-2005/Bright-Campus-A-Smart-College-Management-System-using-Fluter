import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserDetails(String email) async {
    final doc = await _db.collection('users').doc(email).get();
    return doc.exists ? doc.data() : null;
  }
}