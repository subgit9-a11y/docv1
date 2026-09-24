import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/community/community_controller.dart';
import 'package:doctro/features/community/community_screen.dart';
import 'package:doctro/features/community/models/community_post.dart';
import 'package:doctro/features/community/models/workshop.dart';

void main() {
  testWidgets('shows the feed and likes a post via its like control',
      (WidgetTester tester) async {
    final controller = CommunityController(posts: [
      CommunityPost(
        id: 'p1',
        authorName: 'Bocchi The Rock',
        content: 'Loving the community!',
        category: CommunityPostCategory.health,
        comments: 3,
        postedAt: DateTime(2026, 1, 1),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: CommunityScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(controller.isLiked('p1'), isTrue);
  });

  testWidgets('switches to the Resource tab and opens a workshop detail',
      (WidgetTester tester) async {
    final controller = CommunityController(workshops: [
      Workshop(
        id: 'w1',
        title: 'Managing Your Diabetes',
        hostName: 'Dr. Hannibal Lector',
        dateTime: DateTime(2026, 9, 8, 8),
        overview: 'Learn how to manage blood sugar levels.',
        entryPrice: 25,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: CommunityScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resource'));
    await tester.pumpAndSettle();

    expect(find.text('Managing Your Diabetes'), findsOneWidget);

    await tester.tap(find.text('Managing Your Diabetes'));
    await tester.pumpAndSettle();

    expect(find.text('Workshop Detail'), findsOneWidget);
    expect(find.text('Entry Price \$25.00'), findsOneWidget);
  });
}
