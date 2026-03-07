import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentModel {
  final String? id;
  final DateTime date;
  final List<String> symptoms;
  final int painLevel;
  final int riskScore;
  final String riskLevel;

  AssessmentModel({
    this.id,
    required this.date,
    required this.symptoms,
    required this.painLevel,
    required this.riskScore,
    required this.riskLevel,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> data, String id) {
    return AssessmentModel(
      id: id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      painLevel: data['painLevel'] ?? 0,
      riskScore: data['riskScore'] ?? 0,
      riskLevel: data['riskLevel'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'symptoms': symptoms,
      'painLevel': painLevel,
      'riskScore': riskScore,
      'riskLevel': riskLevel,
    };
  }
}
