import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/authentication/view_models/signin_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('SignInViewModel Tests', () {
    test('Initial State is correct', () {
      final viewModel = SignInViewModel(autoInitialize: false);
      expect(viewModel.isOtpLoginMode, isFalse);
      expect(viewModel.isHidden, isTrue);
      expect(viewModel.otpSent, isFalse);
      expect(viewModel.verificationId, isNull);
    });

    test('Toggles OTP mode correctly', () {
      final viewModel = SignInViewModel(autoInitialize: false);

      viewModel.toggleOtpLoginMode(true);
      expect(viewModel.isOtpLoginMode, isTrue);

      viewModel.toggleOtpLoginMode(false);
      expect(viewModel.isOtpLoginMode, isFalse);
    });

    test('Toggles Password Visibility correctly', () {
      final viewModel = SignInViewModel(autoInitialize: false);

      expect(viewModel.isHidden, isTrue);

      viewModel.togglePasswordVisibility();
      expect(viewModel.isHidden, isFalse);

      viewModel.togglePasswordVisibility();
      expect(viewModel.isHidden, isTrue);
    });
  });
}
