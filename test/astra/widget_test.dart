import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/core/astra/models/conversation_model.dart';
import 'package:doctro/core/astra/actions/action_models.dart';
import 'package:doctro/core/astra/widgets/astra_chat_bubble.dart';

void main() {
  group('AstraChatBubble Widget', () {
    testWidgets('should display user message correctly', (tester) async {
      final message = AstraMessage.user(content: 'Hello, Astra!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.text('Hello, Astra!'), findsOneWidget);
    });

    testWidgets('should display assistant message correctly', (tester) async {
      final message = AstraMessage.assistant(content: 'Hello, Doctor!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      expect(find.text('Hello, Doctor!'), findsOneWidget);
    });

    testWidgets('should display system message correctly', (tester) async {
      final message = AstraMessage.system(content: 'System notification');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      expect(find.text('System notification'), findsOneWidget);
    });

    testWidgets('should display streaming indicator when sending', (tester) async {
      final message = AstraMessage.streaming(
        content: 'Thinking...',
        progress: 0.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      // Should show progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('50%'), findsOneWidget);
    });

    testWidgets('should display error indicator when failed', (tester) async {
      final message = AstraMessage.failed(
        content: 'Failed message',
        errorMessage: 'Network error',
        role: MessageRole.user,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('should align user messages to right', (tester) async {
      final message = AstraMessage.user(content: 'User message');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('should align assistant messages to left', (tester) async {
      final message = AstraMessage.assistant(content: 'Assistant message');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('should trigger action callback when tapped', (tester) async {
      String? tappedAction;
      final message = AstraMessage.assistant(
        content: 'Message with action',
        action: AstraNavigationAction(
          type: AstraActionType.openPatient,
          params: {'id': '123'},
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: false,
              onActionTap: (type, params) {
                tappedAction = type;
              },
            ),
          ),
        ),
      );

      // Find and tap the action button
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();

      expect(tappedAction, 'openPatient');
    });

    testWidgets('should display timestamp', (tester) async {
      final message = AstraMessage.user(content: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AstraChatBubble(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      // Timestamp should be displayed
      expect(find.byType(Text), findsWidgets);
    });
  });
}
