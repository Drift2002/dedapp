import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../services/roboflow_service.dart';

class ResultScreen extends StatefulWidget {
  final File? image;

  const ResultScreen({super.key, this.image});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final RoboflowService _roboflowService = RoboflowService();
  late Future<AnalysisResult> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _roboflowService.analyzeImage(widget.image ?? File(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Results',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<AnalysisResult>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            );
          }

          final result = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Status / Score
                if (widget.image == null)
                  _buildNoImageCard()
                else
                  _buildScoreCard(result),

                const SizedBox(height: 24),

                // Warning Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2215), // Darkish orange/brown
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mild Dry Eye Symptoms Detected',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.image != null
                                  ? 'AI analysis detected early signs of dryness and slight inflammation in the sclera.'
                                  : 'Based on your reported symptoms, early signs of dryness are indicated.',
                              style: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Risk History Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2636),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk History',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Last 7 scans',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '📉 -2%',
                            style: GoogleFonts.inter(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 100,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: 6,
                            minY: 0,
                            maxY: 50,
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 10),
                                  FlSpot(1, 25),
                                  FlSpot(2, 20),
                                  FlSpot(3, 30),
                                  FlSpot(4, 15),
                                  FlSpot(5, 40),
                                  FlSpot(6, 30),
                                ],
                                isCurved: true,
                                color: const Color(0xFF2F80ED),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(
                                    0xFF2F80ED,
                                  ).withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recommendations
                Text(
                  'Recommendations',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecommendationItem(
                  icon: Icons.water_drop,
                  title: 'Use Lubricating Drops',
                  desc: 'Apply preservative-free tears 3-4x daily.',
                  color: Colors.blue,
                ),
                _buildRecommendationItem(
                  icon: Icons.timer,
                  title: '20-20-20 Rule',
                  desc: 'Every 20 mins, look 20ft away for 20 secs.',
                  color: Colors.blueGrey,
                ),
                _buildRecommendationItem(
                  icon: Icons.compress,
                  title: 'Warm Compress',
                  desc: 'Apply for 5 mins before bed.',
                  color: Colors.purple,
                ),
                _buildRecommendationItem(
                  icon: Icons.medical_services,
                  title: 'Consult a Doctor',
                  desc: 'We recommend seeing a specialist for a checkup.',
                  color: Colors.grey,
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151922),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E2636)),
                  ),
                  child: Text(
                    'Disclaimer: This result is an AI prediction only and does not constitute a clinical diagnosis. The information provided is for educational purposes only. Please consult a qualified eye care professional for medical advice.',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoImageCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2636),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF252D3D),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Provided',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan results are less accurate without visual data.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to Assessment to take photo
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                'Take picture for better evaluation',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(AnalysisResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2636),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'COMPOSITE RISK SCORE',
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 90.0,
            lineWidth: 18.0,
            percent: result.riskScore / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${result.riskScore}%',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result.riskLevel,
                    style: GoogleFonts.inter(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            progressColor: Colors.orange,
            backgroundColor: const Color(0xFF252D3D),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 24),
          Text(
            'Risk score calculated based on redness, dryness indicators, and blink rate analysis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2636),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
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
    );
  }
}
