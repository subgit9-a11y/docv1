import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/medications/medication_controller.dart';
import 'package:doctro/features/medications/medication_management_screen.dart';
import 'package:doctro/models/astra/prescription_model.dart';

void main() {
  testWidgets('shows the empty state and adds a manual medication',
      (WidgetTester tester) async {
    final controller = MedicationController();

    await tester.pumpWidget(
      MaterialApp(
        home: MedicationManagementScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Medications!'), findsOneWidget);

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Amoxiciline'), 'Vitamin D');
    await tester.tap(find.text('Add Medication').last);
    await tester.pumpAndSettle();

    expect(find.text('No Medications!'), findsNothing);
    expect(find.text('Vitamin D'), findsOneWidget);
    expect(find.text('Self-added'), findsOneWidget);
  });

  testWidgets('logging a dose updates the adherence card',
      (WidgetTester tester) async {
    final controller = MedicationController(prescriptions: [
      AstraPrescription(
        prescriptionId: 'rx-1',
        doctorId: 'doc-1',
        medicines: [MedicineItem(medicineName: 'Ibuprofen', dose: '200mg')],
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: MedicationManagementScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prescribed by Dr. doc-1'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);

    await tester.tap(find.text('Take'));
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
  });
}
