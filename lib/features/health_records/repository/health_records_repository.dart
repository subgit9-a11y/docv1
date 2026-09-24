import 'package:doctro/features/health_records/models/appointment_summary.dart';
import 'package:doctro/features/health_records/models/health_document.dart';
import 'package:doctro/features/health_records/models/medical_history_entry.dart';
import 'package:doctro/features/medications/models/medication.dart';

/// The data seam for Electronic Health Records.
///
/// A real implementation of this needs a Firestore schema and access-control
/// rules that decide who can read and write a patient's records - the
/// patient themselves, the treating doctor, and any doctor the patient has
/// explicitly shared records with - which is a product/security decision
/// for the team to make deliberately, not something to freeze in here
/// unreviewed. [HealthRecordsScreen] is built against this interface so
/// that decision can land later as a `FirestoreHealthRecordsRepository`
/// without any UI changes. [InMemoryHealthRecordsRepository] is a seeded
/// stand-in so the screen is usable and testable today.
abstract class HealthRecordsRepository {
  Future<List<Medication>> currentMedications();
  Future<List<MedicalHistoryEntry>> medicalHistory();
  Future<List<AppointmentSummary>> appointments();
  Future<List<HealthDocument>> documents();
}

class InMemoryHealthRecordsRepository implements HealthRecordsRepository {
  final List<Medication> _medications;
  final List<MedicalHistoryEntry> _medicalHistory;
  final List<AppointmentSummary> _appointments;
  final List<HealthDocument> _documents;

  InMemoryHealthRecordsRepository({
    List<Medication> medications = const [],
    List<MedicalHistoryEntry> medicalHistory = const [],
    List<AppointmentSummary> appointments = const [],
    List<HealthDocument> documents = const [],
  })  : _medications = medications,
        _medicalHistory = medicalHistory,
        _appointments = appointments,
        _documents = documents;

  @override
  Future<List<Medication>> currentMedications() async => _medications;

  @override
  Future<List<MedicalHistoryEntry>> medicalHistory() async => _medicalHistory;

  @override
  Future<List<AppointmentSummary>> appointments() async => _appointments;

  @override
  Future<List<HealthDocument>> documents() async => _documents;
}
