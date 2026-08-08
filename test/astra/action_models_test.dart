import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/core/astra/actions/action_models.dart';

void main() {
  group('AstraNavigationAction', () {
    test('should create with required fields', () {
      final action = AstraNavigationAction(
        type: AstraActionType.openPatient,
      );

      expect(action.type, AstraActionType.openPatient);
      expect(action.priority, ActionPriority.normal);
      expect(action.requiresConfirmation, false);
    });

    test('should create with all fields', () {
      final action = AstraNavigationAction(
        type: AstraActionType.openPrescription,
        description: 'Open prescription',
        params: {'id': '123'},
        priority: ActionPriority.high,
        requiresConfirmation: true,
        confidence: 0.95,
      );

      expect(action.type, AstraActionType.openPrescription);
      expect(action.description, 'Open prescription');
      expect(action.params, {'id': '123'});
      expect(action.priority, ActionPriority.high);
      expect(action.requiresConfirmation, true);
      expect(action.confidence, 0.95);
    });

    test('should extract target ID from params', () {
      final action = AstraNavigationAction(
        type: AstraActionType.openPatient,
        params: {'id': '123'},
      );

      expect(action.targetId, '123');
    });

    test('should extract patient ID from params', () {
      final action = AstraNavigationAction(
        type: AstraActionType.openPatient,
        params: {'patient_id': '456'},
      );

      expect(action.patientId, '456');
    });

    test('should convert to JSON and back', () {
      final original = AstraNavigationAction(
        type: AstraActionType.openCart,
        description: 'Open cart',
        params: {'id': '123'},
        priority: ActionPriority.high,
      );

      final json = original.toJson();
      final restored = AstraNavigationAction.fromJson(json);

      expect(restored.type, original.type);
      expect(restored.description, original.description);
      expect(restored.priority, original.priority);
    });

    test('should create from JSON with various formats', () {
      final json = {
        'type': 'openPatient',
        'description': 'View patient',
        'params': {'id': '789'},
        'priority': 'high',
      };

      final action = AstraNavigationAction.fromJson(json);

      expect(action.type, AstraActionType.openPatient);
      expect(action.description, 'View patient');
      expect(action.params?['id'], '789');
      expect(action.priority, ActionPriority.high);
    });

    test('should create from string', () {
      final action = AstraNavigationAction.fromString('openPatient');

      expect(action.type, AstraActionType.openPatient);
    });

    test('should handle aliases', () {
      expect(
        AstraNavigationAction.fromString('patient').type,
        AstraActionType.openPatient,
      );
      expect(
        AstraNavigationAction.fromString('prescription').type,
        AstraActionType.openPrescription,
      );
      expect(
        AstraNavigationAction.fromString('chat').type,
        AstraActionType.openChat,
      );
    });

    test('should return unknown for invalid actions', () {
      final action = AstraNavigationAction.fromString('invalidAction');

      expect(action.type, AstraActionType.unknown);
    });

    test('should have correct display names', () {
      expect(
        AstraNavigationAction(type: AstraActionType.openPatient).displayName,
        'Open Patient',
      );
      expect(
        AstraNavigationAction(type: AstraActionType.openPrescription).displayName,
        'Open Prescription',
      );
      expect(
        AstraNavigationAction(type: AstraActionType.openPayment).displayName,
        'Open Payment',
      );
    });
  });

  group('AstraActionType', () {
    test('should have all expected action types', () {
      expect(AstraActionType.values.length, 16);
      expect(AstraActionType.values.contains(AstraActionType.openPatient), true);
      expect(AstraActionType.values.contains(AstraActionType.openPrescription), true);
      expect(AstraActionType.values.contains(AstraActionType.openCart), true);
      expect(AstraActionType.values.contains(AstraActionType.openPayment), true);
      expect(AstraActionType.values.contains(AstraActionType.goBack), true);
      expect(AstraActionType.values.contains(AstraActionType.unknown), true);
    });
  });

  group('ActionPriority', () {
    test('should have all expected priorities', () {
      expect(ActionPriority.values.length, 4);
      expect(ActionPriority.values.contains(ActionPriority.low), true);
      expect(ActionPriority.values.contains(ActionPriority.normal), true);
      expect(ActionPriority.values.contains(ActionPriority.high), true);
      expect(ActionPriority.values.contains(ActionPriority.critical), true);
    });
  });

  group('ActionResult', () {
    test('should create success result', () {
      final result = ActionResult.success(data: {'id': '123'});

      expect(result.success, true);
      expect(result.errorMessage, isNull);
      expect(result.data, {'id': '123'});
    });

    test('should create failure result', () {
      final result = ActionResult.failure('Something went wrong');

      expect(result.success, false);
      expect(result.errorMessage, 'Something went wrong');
      expect(result.data, isNull);
    });
  });
}
