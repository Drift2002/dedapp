import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class Symptom {
  final String name;
  final IconData icon;
  bool isSelected;

  Symptom(this.name, this.icon, {this.isSelected = false});
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final List<Symptom> _symptoms = [
    Symptom('Redness', Icons.visibility_off_outlined),
    Symptom('Itching', Icons.pan_tool_alt_outlined),
    Symptom('Blurred Vision', Icons.blur_on),
    Symptom(
      'Dryness',
      Icons.water_drop_outlined,
      isSelected: true,
    ), // Default selected per UI
    Symptom('Watery Eyes', Icons.opacity),
    Symptom('Light Sensitive', Icons.wb_sunny_outlined),
  ];

  double _painLevel = 4;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/result', arguments: File(photo.path));
    }
  }

  void _proceedWithoutImage() {
    Navigator.pushNamed(context, '/result', arguments: null);
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
          'Assessment',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step 2 of 4',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
                Text(
                  '50%',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2F80ED),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2F80ED),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),

            // Question
            Text(
              'What symptoms are you experiencing today?',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply.',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),

            // Symptoms Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: _symptoms.length,
              itemBuilder: (context, index) {
                final symptom = _symptoms[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      symptom.isSelected = !symptom.isSelected;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2636),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            symptom.isSelected
                                ? const Color(0xFF2F80ED)
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                symptom.icon,
                                color:
                                    symptom.isSelected
                                        ? const Color(0xFF2F80ED)
                                        : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                symptom.name,
                                style: GoogleFonts.inter(
                                  color:
                                      symptom.isSelected
                                          ? const Color(0xFF2F80ED)
                                          : Colors.grey,
                                  fontWeight:
                                      symptom.isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (symptom.isSelected)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF2F80ED),
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Pain Level
            Text(
              'How intense is the pain?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Slide to select from 1 to 10.',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2636),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2F80ED),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _painLevel.round().toString(),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.grey[700],
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Colors.white,
                      overlayColor: const Color(0xFF2F80ED).withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _painLevel,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          _painLevel = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NO PAIN',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'MODERATE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'SEVERE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Capture Image Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Text(
                  'Capture Eye Image',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Proceed without Image logic (Text button)
            Center(
              child: TextButton(
                onPressed: _proceedWithoutImage,
                child: Text(
                  'Proceed to results',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
