# Astra Core Test Suite

This directory contains comprehensive tests for the Astra Core module.

## Running Tests

### Run All Tests
```bash
flutter test test/astra/
```

### Run Specific Test File
```bash
flutter test test/astra/astra_core_test.dart
flutter test test/astra/conversation_model_test.dart
flutter test test/astra/action_models_test.dart
```

### Run with Coverage
```bash
flutter test --coverage test/astra/
```

### Run Widget Tests Only
```bash
flutter test test/astra/widget_test.dart
```

## Test Files

| File | Description | Coverage |
|------|-------------|----------|
| `astra_core_test.dart` | AstraConfig utility tests | Configuration, endpoints, URL building |
| `conversation_model_test.dart` | Message and context model tests | AstraMessage, ConversationContext |
| `action_models_test.dart` | Action and priority model tests | AstraNavigationAction, ActionResult |
| `astra_exception_test.dart` | Exception handling tests | All exception types |
| `astra_logger_test.dart` | Logger utility tests | Logging methods |
| `action_dispatcher_test.dart` | Action dispatcher tests | Action extraction, priority sorting |
| `widget_test.dart` | Widget tests | AstraChatBubble |
| `astra_integration_test.dart` | Integration tests | Component interaction |

## Test Coverage Goals

- ✅ Unit tests for all models
- ✅ Unit tests for utilities
- ✅ Unit tests for action dispatcher
- ✅ Widget tests for chat bubble
- ✅ Integration tests for message flows
- ⏳ Service layer tests (requires mock server)
- ⏳ Repository tests (requires Hive mock)

## Mock Dependencies

Some tests require mocking external dependencies:

- `AstraService` - Requires mock HTTP client
- `AstraRepository` - Requires Hive mock
- `AppRouter` - Requires navigation mock

## Adding New Tests

1. Create test file: `test/astra/[feature]_test.dart`
2. Import required packages
3. Use `group()` to organize tests
4. Use `testWidgets()` for widget tests
5. Use `test()` for unit tests

Example:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/core/astra/...';

void main() {
  group('FeatureName', () {
    test('should do something', () {
      // Arrange
      final item = Item();
      
      // Act
      final result = item.doSomething();
      
      // Assert
      expect(result, expectedValue);
    });
  });
}
```

## CI/CD Integration

Add to your CI pipeline:
```yaml
- name: Run Astra Core Tests
  run: flutter test test/astra/
```
