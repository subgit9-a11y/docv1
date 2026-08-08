# Astra AI Integration Guide

## Overview

Astra AI is an intelligent assistant layer that enhances the Doctor App with AI-powered features. This guide covers integration, configuration, and best practices.

---

## Quick Start

### 1. Add Provider to App

```dart
// lib/main.dart
import 'package:doctro/core/astra/providers/astra_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ... existing providers
        ChangeNotifierProvider(create: (_) => AstraController()),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Open Astra Chat

```dart
import 'package:doctro/features/consultation/astra_chat/astra_chat_page.dart';

// Navigate to Astra Chat
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AstraChatPage(
      patientId: 'patient_123',
      patientName: 'John Doe',
    ),
  ),
);
```

### 3. Use AI Button in Any Screen

```dart
import 'package:doctro/widgets/astra_ai_button.dart';

 AstraAIAboutButton(
  onPressed: () {
    // Open Astra with current context
    AstraController().initialize(
      patientId: currentPatient.id,
      patientName: currentPatient.name,
    );
    // Navigate to chat
  },
)
```

---

## Architecture

```
Flutter UI
    ↓
AstraController (State Management)
    ↓
AstraRepository (Caching, Offline Queue)
    ↓
AstraService (HTTP, Streaming)
    ↓
FastAPI Backend
    ↓
Astra Brain
    ↓
Tool Registry
    ↓
Business Services
```

---

## Configuration

### Environment Variables

Create `lib/core/astra/.env` or set in your CI/CD:

```env
ASTRA_BASE_URL=https://api.ayureze.in
ASTRA_API_KEY=your_api_key
ASTRA_TIMEOUT_MS=30000
ASTRA_MAX_RETRIES=3
```

### Deep Link Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)

Already configured for:
- `ayureze://` scheme
- `https://ayureze.in` domain

#### iOS (`ios/Runner/Info.plist`)

Already configured for:
- `ayureze://` URL scheme
- `applinks:ayureze.in` associated domain

---

## Core Components

### AstraController

```dart
// Get singleton instance
final controller = AstraController();

// Initialize with context
await controller.initialize(
  patientId: 'patient_123',
  patientName: 'John Doe',
);

// Send message
await controller.sendMessage('What are the pending tasks for this patient?');

// Listen to state changes
controller.addListener(() {
  if (controller.messages.isNotEmpty) {
    updateUI();
  }
});
```

### Available Methods

| Method | Description |
|--------|-------------|
| `initialize()` | Set up conversation context |
| `sendMessage()` | Send message and get response |
| `sendStreamingMessage()` | Stream AI response |
| `cancelStream()` | Cancel ongoing stream |
| `loadMoreMessages()` | Pagination support |
| `clearConversation()` | Clear chat history |
| `generatePrescriptionDraft()` | AI prescription generation |
| `analyzeMedications()` | Drug interaction check |

### Supported Actions

| Action | Navigation |
|--------|------------|
| `OPEN_PATIENT` | Patient details screen |
| `OPEN_PRESCRIPTION` | Prescription view |
| `OPEN_CART` | Shopping cart |
| `OPEN_PAYMENT` | Payment screen |
| `OPEN_NOTIFICATIONS` | Notification list |
| `OPEN_CHAT` | Chat screen |
| `OPEN_VIDEO_CALL` | Video consultation |
| `OPEN_APPOINTMENT` | Appointment view |
| `OPEN_REMINDERS` | Reminder settings |
| `OPEN_REPORT` | Report viewer |

---

## Deep Linking

### URL Formats

```
ayureze://patient/{id}
ayureze://prescription/{id}
ayureze://appointment
ayureze://cart
ayureze://notification
ayureze://report/{id}
ayureze://chat

https://ayureze.in/patient/{id}
https://ayureze.in/prescription/{id}
https://ayureze.in/appointment
```

### Handle in App

```dart
// In your main.dart or router
void handleDeepLink(Uri uri) {
  final path = uri.pathSegments.first;
  final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
  
  switch (path) {
    case 'patient':
      AppRouter.instance.openPatient(patientId: id!);
      break;
    case 'prescription':
      AppRouter.instance.openPrescription(prescriptionId: id!);
      break;
    // ... handle other cases
  }
}
```

---

## Offline Support

Astra automatically queues messages when offline:

```dart
// Messages sent offline are stored locally
// and sent automatically when online
await controller.sendMessage('Follow up with patient');

// Check if message is queued
if (controller.errorMessage?.contains('offline') ?? false) {
  showSnackBar('Message queued for sending');
}
```

---

## Performance Tips

### 1. Preload Context

```dart
// Before opening chat, preload patient context
await controller.preloadContext(
  patientId: patient.id,
  recentSymptoms: 'fever, cough',
);
```

### 2. Memory Management

```dart
// Automatically trims to last 100 messages
controller.trimMessageHistory();

// Or set custom limit
controller.trimMessageHistory(keepLast: 50);
```

### 3. Pagination

```dart
// For long conversations, use pagination
if (controller.shouldLoadMore(firstVisibleIndex)) {
  await controller.loadMoreMessages();
}
```

---

## Error Handling

```dart
try {
  await controller.sendMessage(message);
} on AstraNetworkException catch (e) {
  if (e.isConnectionError) {
    // Show offline message
    showOfflineBanner();
  } else {
    // Show retry option
    showRetryDialog();
  }
} on AstraAuthException {
  // Redirect to login
  redirectToLogin();
} on AstraTimeoutException {
  // Show timeout message
  showTimeoutDialog();
}
```

---

## Testing

```bash
# Run all Astra tests
flutter test test/astra/

# Run with coverage
flutter test --coverage test/astra/

# Run specific test file
flutter test test/astra/action_dispatcher_test.dart
```

---

## File Structure

```
lib/core/astra/
├── astra_core.dart           # Main export
├── actions/
│   ├── action_models.dart    # Action types
│   ├── action_dispatcher.dart # Navigation handler
│   └── actions.dart          # Exports
├── controllers/
│   └── astra_controller.dart # State management
├── models/
│   └── conversation_model.dart # Message models
├── navigation/
│   └── app_router.dart       # Deep link routing
├── repositories/
│   └── astra_repository.dart # Data layer
├── services/
│   └── astra_service.dart   # API client
├── utils/
│   ├── astra_cache.dart     # Performance cache
│   ├── astra_config.dart    # Configuration
│   ├── astra_exception.dart  # Error types
│   └── astra_logger.dart    # Logging
└── widgets/
    ├── astra_action_chip.dart
    └── astra_chat_bubble.dart
```

---

## Troubleshooting

### "Astra not responding"

1. Check network connection
2. Verify `ASTRA_BASE_URL` is correct
3. Check API key validity
4. Review logs: `AstraLogger.setLevel(AstraLogger.levelDebug)`

### "Actions not navigating"

1. Ensure AppRouter methods are connected to screens
2. Check that screens are registered in navigation
3. Verify deep link scheme is installed

### "Slow responses"

1. Enable caching: Already enabled by default
2. Preload context: Use `preloadContext()` before chat
3. Check network latency
4. Consider reducing message history

---

## Best Practices

1. **Always initialize before use**
   ```dart
   await controller.initialize(patientId: id);
   ```

2. **Dispose properly**
   ```dart
   @override
   void dispose() {
     controller.dispose();
     super.dispose();
   }
   ```

3. **Use context preloading** for faster initial response

4. **Handle errors gracefully** with try-catch

5. **Keep messages trimmed** for memory efficiency

6. **Use semantic labels** for accessibility

---

## Support

For issues or questions:
- Check `/docs/ASTRA_TROUBLESHOOTING.md`
- Review test files for usage examples
- Contact the Astra team

---

*Last Updated: ${new Date().toISOString().split('T')[0]}*
