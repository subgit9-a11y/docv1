// Temporary screenshot gallery for the newly built Osler kit screens.
// Not part of the app - boots straight into each screen with seed data,
// skipping sign-in/Firebase, so they can be visually reviewed quickly.
import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/features/errors/error_utility_screen.dart';
import 'package:doctro/features/search/search_screen.dart';
import 'package:doctro/features/medications/medication_controller.dart';
import 'package:doctro/features/medications/medication_management_screen.dart';
import 'package:doctro/features/health_records/health_records_screen.dart';
import 'package:doctro/features/health_records/repository/health_records_repository.dart';
import 'package:doctro/features/health_records/models/appointment_summary.dart';
import 'package:doctro/features/health_records/models/health_document.dart';
import 'package:doctro/features/health_records/models/medical_history_entry.dart';
import 'package:doctro/features/medications/models/medication.dart';
import 'package:doctro/features/community/community_controller.dart';
import 'package:doctro/features/community/community_screen.dart';
import 'package:doctro/features/community/models/community_post.dart';
import 'package:doctro/features/community/models/workshop.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_controller.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_screen.dart';
import 'package:doctro/models/astra/prescription_model.dart';

void main() {
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      debugShowCheckedModeBanner: false,
      theme: AyurezeTheme.lightTheme(),
      darkTheme: AyurezeTheme.darkTheme(),
      routes: {
        '/': (context) => const _GalleryHome(),
        'notFound': (context) =>
            const ErrorUtilityScreen(kind: ErrorUtilityKind.notFound),
        'noInternet': (context) =>
            const ErrorUtilityScreen(kind: ErrorUtilityKind.noInternet),
        'internalError': (context) =>
            const ErrorUtilityScreen(kind: ErrorUtilityKind.internalError),
        'maintenance': (context) =>
            const ErrorUtilityScreen(kind: ErrorUtilityKind.maintenance),
        'notAllowed': (context) =>
            const ErrorUtilityScreen(kind: ErrorUtilityKind.notAllowed),
        'search': (context) => const SearchScreen(),
        'medications': (context) => MedicationManagementScreen(
              controller: MedicationController(prescriptions: [
                AstraPrescription(
                  prescriptionId: 'rx-1',
                  doctorId: 'Hannibal Lector',
                  medicines: [
                    MedicineItem(
                      medicineName: 'Amoxiciline',
                      dose: '250mg',
                      schedule: '1-0-1',
                      timing: 'Before Eating',
                    ),
                    MedicineItem(
                      medicineName: 'Ibuprofen',
                      dose: '200mg',
                      schedule: '0-1-0',
                      timing: 'After Eating',
                    ),
                  ],
                ),
              ]),
            ),
        'healthRecords': (context) => HealthRecordsScreen(
              repository: InMemoryHealthRecordsRepository(
                medications: const [
                  Medication(
                    id: 'm1',
                    name: 'Amoxiciline',
                    dosage: '250mg - Morning, Night',
                    timing: 'Before Eating',
                    source: MedicationSource.prescribed,
                    prescribingDoctorName: 'Dr. Hannibal Lector',
                  ),
                ],
                medicalHistory: const [
                  MedicalHistoryEntry(
                    id: 'h1',
                    bodySystem: BodySystem.heart,
                    title: 'Pulmonary Function Test',
                    summary: 'Excellent Health',
                  ),
                  MedicalHistoryEntry(
                    id: 'h2',
                    bodySystem: BodySystem.gut,
                    title: 'Stool/Fecal Analysis',
                    summary: 'Bacterial Guts detected',
                    flagged: true,
                  ),
                ],
                appointments: [
                  AppointmentSummary(
                    id: 'a1',
                    doctorName: 'Dr. Phos Gray',
                    type: 'General Medical Checkup',
                    dateTime: DateTime(2026, 1, 3, 15, 30),
                  ),
                ],
                documents: const [
                  HealthDocument(
                    id: 'd1',
                    title: 'X-Ray Scans',
                    category: 'Diagnostics',
                    sizeLabel: '24mb',
                  ),
                  HealthDocument(
                    id: 'd2',
                    title: 'Blood Test',
                    category: 'Diagnostics',
                    sizeLabel: '123mb',
                  ),
                ],
              ),
            ),
        'community': (context) => CommunityScreen(
              controller: CommunityController(
                posts: [
                  CommunityPost(
                    id: 'p1',
                    authorName: 'Bocchi The Rock',
                    content:
                        'Loving the community vibe and insights shared with others! Used Osler for my health journey.',
                    category: CommunityPostCategory.health,
                    likes: 118,
                    comments: 15,
                    postedAt: DateTime.now().subtract(const Duration(hours: 3)),
                  ),
                  CommunityPost(
                    id: 'p2',
                    authorName: 'Dr. Hannibal Lector',
                    content:
                        'What type of insights would you like to be shared by doctors in our community? Vote or drop your suggestions below!',
                    category: CommunityPostCategory.doctor,
                    likes: 24,
                    comments: 11,
                    postedAt: DateTime.now().subtract(const Duration(days: 2)),
                  ),
                ],
                workshops: [
                  Workshop(
                    id: 'w1',
                    title: 'Managing Your Diabetes',
                    hostName: 'Dr. Hannibal Lector',
                    dateTime: DateTime(2026, 9, 8, 8),
                    overview:
                        'Discover the power of holistic health with Osler\'s Wellness Tech workshop.',
                    agenda: const [
                      'Introduction to Osler',
                      'Health Metrics 101',
                      'Telehealth in Action',
                    ],
                    entryPrice: 25,
                  ),
                ],
              ),
            ),
        'healthAssessment': (context) => HealthAssessmentScreen(
              controller: HealthAssessmentController(),
              onFinish: () {},
            ),
      },
    );
  }
}

class _GalleryHome extends StatelessWidget {
  const _GalleryHome();

  @override
  Widget build(BuildContext context) {
    final routes = [
      'notFound',
      'noInternet',
      'internalError',
      'maintenance',
      'notAllowed',
      'search',
      'medications',
      'healthRecords',
      'community',
      'healthAssessment',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: ListView(
        children: [
          for (final route in routes)
            ListTile(
              title: Text(route),
              onTap: () => Navigator.of(context).pushNamed(route),
            ),
        ],
      ),
    );
  }
}
