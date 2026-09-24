/// A lightweight appointment entry for the Health Records "My Appointments"
/// tab. Deliberately its own small model rather than the REST-API-shaped
/// UpcomingAppointment/PastAppointment in lib/models/appointment_history.dart
/// - this tab only needs enough to render a row, and keeping it separate
/// means the appointments API's response shape can change without touching
/// this screen.
class AppointmentSummary {
  final String id;
  final String doctorName;
  final String type;
  final DateTime dateTime;

  const AppointmentSummary({
    required this.id,
    required this.doctorName,
    required this.type,
    required this.dateTime,
  });
}
