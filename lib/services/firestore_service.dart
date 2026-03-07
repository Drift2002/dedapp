import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/assessment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return uid;
  }

  // Create User Profile
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    UserModel newUser = UserModel(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set(newUser.toMap());
  }

  // Get User Profile
  Future<UserModel?> getUserProfile() async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(_currentUid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Add Assessment Result
  Future<void> addAssessmentResult(AssessmentModel assessment) async {
    await _db
        .collection('users')
        .doc(_currentUid)
        .collection('assessments')
        .add(assessment.toMap());
  }

  // Get Recent Assessments Stream
  Stream<List<AssessmentModel>> getAssessments({int limit = 7}) {
    return _db
        .collection('users')
        .doc(_currentUid)
        .collection('assessments')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AssessmentModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get Last Assessment
  Future<AssessmentModel?> getLastAssessment() async {
    var snapshot = await _db
        .collection('users')
        .doc(_currentUid)
        .collection('assessments')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AssessmentModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    return null;
  }
}
