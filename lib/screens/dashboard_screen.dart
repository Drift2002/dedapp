import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../services/screen_time_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/assessment_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Duration _screenTime = Duration.zero;
  bool _isLoading = true;
  UserModel? _userModel;
  AssessmentModel? _lastAssessment;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    Duration time = await _screenTimeService.getDailyScreenTime();
    UserModel? user = await _firestoreService.getUserProfile();
    AssessmentModel? assessment = await _firestoreService.getLastAssessment();

    if (mounted) {
      setState(() {
        _screenTime = time;
        _userModel = user;
        _lastAssessment = assessment;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141D),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2636),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.favorite,
              color: Color(0xFF2F80ED),
              size: 20,
            ),
          ),
        ),
        title: Text(
          'OcularCare',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[700],
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoading ? 'Hello...' : 'Hello, ${_userModel?.firstName ?? 'User'}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Let's check your eye health status.",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 32),

            // Screen Time Indicator
            Center(
              child: CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 18.0,
                percent: 0.7, // Mock percentage for visual
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_screenTime.inHours}h ${_screenTime.inMinutes.remainder(60)}m',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Daily Screen Time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                progressColor: const Color(0xFF2F80ED),
                backgroundColor: const Color(0xFF1E2636),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 32),

            // Risk Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2636),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: _lastAssessment?.riskLevel == 'High'
                          ? Colors.red
                          : (_lastAssessment?.riskLevel == 'Moderate' ? Colors.orange : Colors.green),
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: Colors.white),
                        children: [
                          const TextSpan(text: 'Risk Level: '),
                          TextSpan(
                            text: _lastAssessment != null ? _lastAssessment!.riskLevel : 'Unknown',
                            style: GoogleFonts.inter(
                              color: _lastAssessment?.riskLevel == 'High'
                                  ? Colors.red
                                  : (_lastAssessment?.riskLevel == 'Moderate' ? Colors.orange : Colors.green),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Take Eye Test Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/assessment');
                },
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Text(
                  'Take Eye Test',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Last Test Result
            if (_lastAssessment != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2636),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Test Result',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2F80ED)),
                          ),
                          child: Text(
                            'Completed',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF2F80ED),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_lastAssessment!.riskScore}/100',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Risk Score',
                              style: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          DateFormat.yMMMd().format(_lastAssessment!.date),
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _lastAssessment!.riskScore / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _lastAssessment!.riskLevel == 'High'
                            ? Colors.red
                            : (_lastAssessment!.riskLevel == 'Moderate' ? Colors.orange : Colors.green),
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Tip of the day
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151922),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E2636)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF2F80ED)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tip of the day',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Follow the 20-20-20 rule to reduce strain.',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await _authService.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.grey),
                label: Text(
                  'Log Out',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
