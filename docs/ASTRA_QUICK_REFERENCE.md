# Astra AI Quick Reference

## One-Line Setup

```dart
// Add to main.dart providers
ChangeNotifierProvider(create: (_) => AstraController()),
```

## Open Chat (3 lines)

```dart
final ctrl = AstraController();
await ctrl.initialize(patientId: '123', patientName: 'John');
await ctrl.sendMessage('Hello Astra!');
```

## State Access

| Property | Type | Description |
|----------|------|-------------|
| `controller.messages` | `List<AstraMessage>` | Chat history |
| `controller.isLoading` | `bool` | Loading state |
| `controller.isStreaming` | `bool` | Streaming state |
| `controller.errorMessage` | `String?` | Error message |
| `controller.pendingActions` | `List<AstraNavigationAction>` | Actions to execute |

## Common Tasks

| Task | Code |
|------|------|
| Send message | `ctrl.sendMessage('Hi')` |
| Stream response | `ctrl.sendStreamingMessage('Hi')` |
| Cancel stream | `ctrl.cancelStream()` |
| Clear chat | `ctrl.clearConversation()` |
| Load more | `ctrl.loadMoreMessages()` |
| Generate Rx | `ctrl.generatePrescriptionDraft(patientId: '123')` |
| Check drugs | `ctrl.analyzeMedications(['Aspirin'])` |

## Deep Links

```
ayureze://patient/{id}
ayureze://prescription/{id}
ayureze://cart
ayureze://appointment
ayureze://notification
ayureze://report/{id}
ayureze://chat
```

## Action Types

| Type | Opens |
|------|-------|
| `openPatient` | Patient details |
| `openPrescription` | Prescription view |
| `openCart` | Shopping cart |
| `openPayment` | Payment screen |
| `openNotifications` | Notifications |
| `openChat` | Chat screen |
| `openVideoCall` | Video consultation |
| `openAppointment` | Appointment view |
| `openReminders` | Reminder settings |
| `openReport` | Report viewer |

## Error Types

```dart
AstraNetworkException   // Network/connection errors
AstraAuthException     // Authentication failed
AstraTimeoutException  // Request timed out
AstraServerException  // Server error (5xx)
AstraParseException   // Response parsing failed
AstraActionException  // Action execution failed
```

## Logger Levels

```dart
AstraLogger.levelVerbose  // 0 - All logs
AstraLogger.levelDebug    // 1 - Debug & above
AstraLogger.levelInfo     // 2 - Info & above (default)
AstraLogger.levelWarning  // 3 - Warnings & above
AstraLogger.levelError    // 4 - Errors only
```

## Performance Tips

| Tip | How |
|-----|-----|
| Fast responses | `ctrl.preloadContext(patientId: id)` |
| Save memory | `ctrl.trimMessageHistory(keepLast: 50)` |
| Pagination | `ctrl.loadMoreMessages()` |
| Caching | Enabled by default (30min TTL) |

## Testing

```bash
# All tests
flutter test test/astra/

# Single file
flutter test test/astra/action_dispatcher_test.dart
```

## Key Files

```
lib/core/astra/
├── controllers/astra_controller.dart   ← Main controller
├── services/astra_service.dart         ← API calls
├── repositories/astra_repository.dart   ← Data/caching
├── navigation/app_router.dart           ← Navigation
└── widgets/
    ├── astra_chat_bubble.dart          ← Message bubble
    └── astra_action_chip.dart          ← Action chip
```
