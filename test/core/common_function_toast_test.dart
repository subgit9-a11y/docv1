import 'package:doctro/core/constants/common_function.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for the toast-stacking bug found while auditing
/// profile.dart: several near-simultaneous failed API calls (e.g.
/// treatment() and hospital() both failing on the same screen load) each
/// construct a ServerError, which toasts as a side effect - so the same
/// "Connection failed" text stacked one toast per failure. toastMessage now
/// suppresses an identical message re-fired within a short window.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('PonnamKarthik/fluttertoast');
  final calls = <String>[];

  setUp(() {
    calls.clear();
    CommonFunction.resetToastDedupeForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'showToast') {
        calls.add((call.arguments as Map)['msg'] as String);
      }
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('suppresses the same message re-fired immediately after', () {
    CommonFunction.toastMessage('Connection failed. Please check internet');
    CommonFunction.toastMessage('Connection failed. Please check internet');
    CommonFunction.toastMessage('Connection failed. Please check internet');

    expect(calls, ['Connection failed. Please check internet']);
  });

  test('does not suppress a different message', () {
    CommonFunction.toastMessage('Connection failed. Please check internet');
    CommonFunction.toastMessage('Session expired. Please log in again.');

    expect(calls, [
      'Connection failed. Please check internet',
      'Session expired. Please log in again.',
    ]);
  });

  test('shows the same message again once the dedupe window elapses', () async {
    CommonFunction.toastMessage('Connection failed. Please check internet');
    // toastMessage() itself has no clock injection point; sleeping the
    // actual dedupe window is the only way to exercise this branch.
    await Future.delayed(const Duration(seconds: 3, milliseconds: 100));
    CommonFunction.toastMessage('Connection failed. Please check internet');

    expect(calls, [
      'Connection failed. Please check internet',
      'Connection failed. Please check internet',
    ]);
  });
}
