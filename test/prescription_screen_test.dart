import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/prescription/astra/prescription_screen.dart';

void main() {
  testWidgets('PrescriptionScreen builds correctly and catches map type error',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PrescriptionScreen(
          patientId: '123',
          patientName: 'Test Patient',
          patientPhone: '1234567890',
          doctorId: 'DOC1',
          astraFillData: const {
            'extracted_symptoms': ['fever', 'cough'],
          },
        ),
      ),
    ));

    expect(find.text('Prescription for Test Patient'), findsOneWidget);
  });
}
