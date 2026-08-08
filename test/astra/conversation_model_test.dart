import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/core/astra/models/conversation_model.dart';
import 'package:doctro/core/astra/actions/action_models.dart';

void main() {
  group('AstraMessage', () {
    test('should create user message', () {
      final message = AstraMessage.user(content: 'Hello');

      expect(message.content, 'Hello');
      expect(message.role, MessageRole.user);
      expect(message.status, MessageStatus.sent);
      expect(message.id.isNotEmpty, true);
    });

    test('should create assistant message', () {
      final message = AstraMessage.assistant(content: 'Hi there!');

      expect(message.content, 'Hi there!');
      expect(message.role, MessageRole.assistant);
      expect(message.status, MessageStatus.received);
    });

    test('should create system message', () {
      final message = AstraMessage.system(content: 'System info');

      expect(message.content, 'System info');
      expect(message.role, MessageRole.system);
      expect(message.status, MessageStatus.received);
    });

    test('should create error system message', () {
      final message = AstraMessage.system(content: 'Error occurred', isError: true);

      expect(message.status, MessageStatus.failed);
      expect(message.errorMessage, 'Error occurred');
    });

    test('should create streaming message', () {
      final message = AstraMessage.streaming(content: 'Typing...', progress: 0.5);

      expect(message.status, MessageStatus.sending);
      expect(message.role, MessageRole.assistant);
      expect(message.streamProgress, 0.5);
    });

    test('should convert to JSON and back', () {
      final original = AstraMessage.user(content: 'Test message');
      final json = original.toJson();
      final restored = AstraMessage.fromJson(json);

      expect(restored.content, original.content);
      expect(restored.role, original.role);
      expect(restored.id, original.id);
    });

    test('should support copyWith', () {
      final original = AstraMessage.user(content: 'Original');
      final copied = original.copyWith(content: 'Modified');

      expect(copied.content, 'Modified');
      expect(copied.id, original.id);
      expect(copied.role, original.role);
    });

    test('should generate unique IDs', () {
      final msg1 = AstraMessage.user(content: 'Test 1');
      final msg2 = AstraMessage.user(content: 'Test 2');

      expect(msg1.id != msg2.id, true);
    });
  });

  group('ConversationContext', () {
    test('should create with all fields', () {
      final context = ConversationContext(
        patientId: '123',
        patientName: 'John Doe',
        appointmentId: '456',
        prescriptionId: '789',
        screenContext: 'patient_details',
        doctorId: 'doc1',
      );

      expect(context.patientId, '123');
      expect(context.patientName, 'John Doe');
      expect(context.appointmentId, '456');
      expect(context.prescriptionId, '789');
      expect(context.screenContext, 'patient_details');
      expect(context.doctorId, 'doc1');
    });

    test('should convert to metadata map', () {
      final context = ConversationContext(
        patientId: '123',
        patientName: 'John',
      );

      final metadata = context.toMetadata();

      expect(metadata['patient_id'], '123');
      expect(metadata['patient_name'], 'John');
      expect(metadata['timestamp'], isNotNull);
      expect(metadata['appointment_id'], isNull);
    });

    test('should support copyWith', () {
      final original = ConversationContext(patientId: '123');
      final copied = original.copyWith(patientName: 'Jane');

      expect(copied.patientId, '123');
      expect(copied.patientName, 'Jane');
    });
  });
}
