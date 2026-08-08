# Astra Doctor App - Architecture Report
## Phase 1: Project Analysis & Architecture Documentation

---

## 1. Executive Summary

The Astra Doctor App is an enterprise-grade Flutter healthcare application for doctors to manage patients, appointments, prescriptions, video consultations, and payments. The app currently uses Firebase for real-time features, Supabase for backend integration, and is integrated with Astra AI Backend (https://astra.ayureze.in) for AI-powered features.

**Objective**: Extend the existing application with Astra AI integration WITHOUT breaking existing functionality.

---

## 2. Current Project Architecture

### 2.1 Technology Stack
| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.4.4+ (Material 3) |
| State Management | Provider |
| Backend Communication | Dio (with Retrofit) |
| Authentication | Firebase Auth + App Token |
| Real-time Features | Firebase Firestore |
| Database/Backend | Supabase + FastAPI Backend |
| Payments | Multiple (Stripe, Razorpay, PayStack, etc.) |
| Video Calling | Agora RTC Engine |
| AI Backend | Astra Brain (https://astra.ayureze.in) |

### 2.2 Folder Structure (Current)
```
lib/
├── core/
│   ├── constants/
│   ├── localization/
│   └── navigator_key.dart
├── features/
│   ├── appointments/
│   ├── authentication/
│   ├── cashfree/
│   ├── consultation/
│   │   ├── chat/           # Firebase-based chat
│   │   └── videoCall/
│   ├── dashboard/
│   ├── notifications/
│   ├── prescription/
│   │   └── astra/          # Existing Astra prescription screen
│   ├── profile/
│   ├── review/
│   ├── schedule/
│   └── settings/
├── models/
│   ├── astra/              # Existing Astra models
│   ├── appointment_details.dart
│   ├── today_appointment.dart
│   └── ...
├── network/
│   ├── api_header.dart
│   ├── apis.dart           # All API endpoints including Astra
│   ├── base_model.dart
│   └── network_api.dart
├── services/
│   ├── astra_api_service.dart  # Existing Astra API service
│   ├── astra_service.dart      # Legacy Astra service
│   └── supabase_service.dart
├── theme/
│   └── ayureze_theme.dart
├── utils/
└── widgets/
```

### 2.3 State Management Pattern
The app uses **Provider** for state management with a consistent pattern:

1. **ViewModel** extends `ChangeNotifier`
2. **Widget** wraps content in `ChangeNotifierProvider`
3. **Consumer/Selector** for efficient rebuilds

Example:
```dart
// ViewModel
class LoginHomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  void fetchData() async { ... notifyListeners(); }
}

// Widget
ChangeNotifierProvider(
  create: (_) => LoginHomeViewModel()..initializeData(context),
  child: Consumer<LoginHomeViewModel>(...)
)
```

### 2.4 Routing Pattern
Two routing mechanisms coexist:

1. **Named Routes** (main.dart):
   ```dart
   routes: {
     'SignIn': (context) => SignIn(),
     'loginHome': (context) => LoginHomeScreen(chat: ""),
     'patientInformation': (context) => patientDetailsScreen(),
     // ...
   }
   Navigator.pushNamed(context, 'loginHome');
   ```

2. **MaterialPageRoute** (for parameterized routes):
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => patientDetailsScreen(id: item.id),
     ),
   );
   ```

### 2.5 Networking Pattern
- **Dio** for HTTP requests
- **Retrofit** for type-safe API clients
- **Interceptors** for auth token injection
- **Base URLs**: Main app API + Astra Backend

### 2.6 Existing Astra Integration
The app already has partial Astra integration:

1. **Models** (`lib/models/astra/`):
   - `ai_response_models.dart` - AI chat, safety analysis, prescriptions
   - `patient_model.dart` - Patient data structures
   - `prescription_model.dart` - Prescription data

2. **Services**:
   - `astra_api_service.dart` - Main API service with all endpoints
   - `astra_service.dart` - Legacy service (maintained for compatibility)

3. **Screens**:
   - `features/prescription/astra/prescription_screen.dart` - Prescription with Astra AI

4. **APIs** (apis.dart):
   - Authentication, Doctor, Patient, Prescription, Shopify, Brain, Astra Fill, Documents, Orders, Notifications

---

## 3. Gaps Identified

### 3.1 Missing Astra Core Infrastructure
| Component | Status | Required |
|-----------|--------|----------|
| AstraService (core) | Partial | Enhancements needed |
| AstraRepository | ❌ Missing | Required |
| AstraController | ❌ Missing | Required |
| ActionDispatcher | ❌ Missing | Required |
| AppRouter | ❌ Missing | Required |
| Astra Conversation State | ❌ Missing | Required |

### 3.2 Missing Features
| Feature | Description |
|---------|-------------|
| Streaming Chat | Real-time Astra Brain chat streaming |
| Action Interpretation | Converting AI responses to navigation |
| Offline Queue | Queue messages when offline |
| Deep Links | Support for `ayureze://` scheme |
| Centralized Error Handling | Consistent error UX |
| Logging | Comprehensive Astra operation logging |

---

## 4. Target Architecture

### 4.1 Proposed Folder Structure
```
lib/
├── core/
│   ├── astra/              # NEW: Astra AI Core
│   │   ├── models/
│   │   ├── services/
│   │   ├── repositories/
│   │   ├── controllers/
│   │   ├── actions/
│   │   ├── navigation/
│   │   ├── widgets/
│   │   └── utils/
│   ├── constants/
│   └── ...
├── features/
│   ├── consultation/chat/  # REUSE existing
│   ├── prescription/astra/  # REUSE + ENHANCE
│   └── ...
├── services/
│   └── astra_api_service.dart  # ENHANCE existing
└── ...
```

### 4.2 Data Flow Architecture
```
Flutter UI
    ↓
AstraController (State Management)
    ↓
AstraRepository (Caching, DTO, Offline Queue)
    ↓
AstraApiService (HTTP, Auth, Streaming)
    ↓
Astra Brain Backend (https://astra.ayureze.in)
    ↓
Tool Registry + Business Services
    ↓
Response with Actions
    ↓
ActionDispatcher (Interprets → Navigation)
    ↓
AppRouter (Routes to Existing Screens)
```

---

## 5. Implementation Plan

### Phase 1: Analysis (COMPLETED ✓)
- [x] Project exploration
- [x] Architecture documentation
- [x] Gap analysis
- [x] This report

### Phase 2: Core Infrastructure
- [ ] Create `lib/core/astra/` directory structure
- [ ] Create AstraCore module with base classes
- [ ] Create AstraConfig for backend configuration

### Phase 3: Service Layer
- [ ] Enhance AstraApiService with streaming support
- [ ] Add retry logic and timeout handling
- [ ] Implement request/response logging

### Phase 4: Repository Layer
- [ ] Create AstraRepository
- [ ] Implement caching strategy
- [ ] Add offline queue
- [ ] DTO conversion

### Phase 5: Controller Layer
- [ ] Create AstraController (ChangeNotifier)
- [ ] Conversation state management
- [ ] Streaming state
- [ ] Loading/error states

### Phase 6: Action Dispatcher
- [ ] Define supported actions
- [ ] Create action interpreter
- [ ] Navigation integration

### Phase 7-18: Feature Integration
(See implementation order in requirements)

---

## 6. Security Considerations

### 6.1 Authentication Flow
1. Firebase Auth token (preferred)
2. App auth token fallback
3. X-Role header for doctor permissions

### 6.2 Data Protection
- Sensitive tokens stored in FlutterSecureStorage
- No plaintext credentials in SharedPreferences
- Certificate bypass only for Astra domain

### 6.3 Network Security
- HTTPS enforced
- DNS fallback for connectivity issues
- IPv4 fallback support

---

## 7. Key API Endpoints (Astra)

| Category | Endpoint | Purpose |
|----------|----------|---------|
| Auth | `api/v1/auth/login` | Login |
| Auth | `api/v1/auth/session` | Create session |
| Brain | `api/v1/brain/chat` | AI chat |
| Brain | `api/v1/brain/health` | Health check |
| Prescriptions | `api/v1/api/prescriptions/create` | Create prescription |
| Shopify | `api/v1/shopify/ai-shop-assist` | Smart cart |
| Astra Fill | `api/v1/astra-fill/process-voice` | Voice processing |

---

## 8. Existing Screens (DO NOT MODIFY)

| Screen | Location | Route |
|--------|----------|-------|
| Login Home | `features/dashboard/login_home.dart` | `loginHome` |
| Patient Info | `features/dashboard/patient_information.dart` | `patientInformation` |
| Prescription | `features/prescription/astra/prescription_screen.dart` | Direct navigation |
| Chat Home | `features/consultation/chat/pages/home_page.dart` | `ChatHome` |
| Notifications | `features/notifications/notifications.dart` | `notifications` |
| Payment | `features/cashfree/payment.dart` | `payment` |

---

## 9. Dependencies

No new dependencies required. Existing dependencies cover:
- **dio**: HTTP client (already in use)
- **provider**: State management (already in use)
- **hive_flutter**: Offline caching (already integrated)
- **firebase_auth**: Authentication (already in use)

---

## 10. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing features | No modifications to existing services/models/screens |
| Authentication failures | Multiple token sources with fallback |
| Network issues | DNS fallback, IPv4 fallback, retry logic |
| Offline mode | Hive-based offline queue |
| Stream disconnections | Automatic reconnection |

---

## 11. Success Criteria

1. ✅ Existing functionality unchanged
2. ✅ Astra chat integrated with existing chat UI
3. ✅ Action dispatcher navigates to existing screens
4. ✅ Error states handled consistently
5. ✅ Offline support with queue
6. ✅ No analyzer warnings
7. ✅ All tests pass
8. ✅ Deep links work

---

*Report Generated: Phase 1 Completion*
*Next Action: Begin Phase 2 - Core Infrastructure Implementation*
