# Doctor app: remaining work to finish the Astra-mediated consultation flow

This picks up exactly where the audit left off (see the patient app's
`docs/backend/astra_doctor_patient_flow.md` in `appayureze-cloud/ayurezepat`
for the full mechanism this builds on). Six items, in the order they actually
block each other.

## 0. Resolve which doctor app repo is canonical (blocks everything below)

Two repos currently claim to be "the doctor app":

- `appayureze-cloud/ayureze-doctor-app`
- `subgit9-a11y/docv1`

Both were audited and fixed separately during this work (see
`claude/astra-doctor-video-wiring` on the first, `claude/fix-astra-service-auth`
on the second). `docv1` is further along - it already has correct Astra auth,
video, and an actively open UI/UX PR (#3) - but that's circumstantial
evidence, not confirmation of which one is actually shipped to doctors today.

**Do this first:** check which one is in Play Store Connect / App Store
Connect as the live build, or ask whoever manages deployment. Everything
below assumes `docv1`, since that's the one with more recent, more complete
Astra work - but if `ayureze-doctor-app` is the real one, the same fixes need
porting there (the patterns are identical, just different file paths - see
that repo's `claude/astra-doctor-video-wiring` commit for the equivalent).

## 1. Merge the three pending branches

Nothing below has shipped yet. Current state:

| Repo | Branch | What it fixes |
|---|---|---|
| `appayureze-cloud/ayurezepat` (patient app) | `claude/focused-dijkstra-7432ar` | Auto-creates an Astra journey/case on booking; fixed an ordering bug in that code |
| `appayureze-cloud/ayureze-doctor-app` | `claude/astra-doctor-video-wiring` | Video calls now use the real Astra gateway instead of a dead Laravel endpoint |
| `subgit9-a11y/docv1` | `claude/fix-astra-service-auth` | One of three duplicate Astra HTTP clients was still sending a raw Firebase token instead of the exchanged Astra JWT |

Review and merge whichever of these apply to the canonical repo from step 0.
The patient-app branch should merge regardless - it's the one that actually
creates the case a doctor would need to see.

## 2. Wire doctor-side case creation/receiving - DONE

Went with Option B below. Backend: added
`GET /api/companion/case/by-doctor/{doctor_id}` (`app/companion_api.py`,
`app/companion_system.py`), plus three real schema bugs found and fixed
along the way that were silently dropping every case to the in-memory
cache (never durably persisted): `journey_health_records.user_id`/
`doctor_id`/`prescription_id` typed as `uuid` instead of `text`, a missing
`record_type` column default, several missing columns on
`companion_journeys`, and a missing `journey_id` FK column on that same
table. All deployed and confirmed live with a real end-to-end test
(journey → case → doctor listing all persisting to Supabase, not cache).

Client: added `docv1`'s "My Cases" screen
(`lib/features/cases/case_list_screen.dart` +
`view_models/case_list_view_model.dart`), reachable from the drawer,
listing diagnosis/status/progress for each case via the new endpoint.

Original options considered below, kept for context.

**The real gap, and it needs a backend decision first.** The patient app
calls `POST /api/companion/case/create` and gets back a `case_id`. The only
way to read a case back is `GET /api/companion/case/{case_id}` - there is
**no endpoint that lists cases by `doctor_id`** (confirmed: grepped the real
backend source, `app/companion_api.py` has exactly three case routes -
`create`, `get-by-id`, `progress` - no listing route). A doctor app has no
way to discover a case_id it was never told.

Two ways to close this, pick one:

**Option A - stitch through the existing Laravel appointment record (no new backend endpoint needed).**
When `linkAppointmentToAstra()` (patient app,
`lib/features/astra/data/astra_consultation_link.dart`) gets a `case_id`
back from `case/create`, also `POST` it back to Laravel against that same
appointment (needs a small Laravel-side field/endpoint addition - something
like `PATCH /api/appointments/{id}` accepting an `astra_case_id` field).
The doctor app already fetches appointment details via Laravel
(`appointment_details/{id}`) - just read `astra_case_id` off that same
response, no new Astra call needed on the doctor side at all.

**Option B - add a real backend endpoint.**
`GET /api/companion/case/by-doctor/{doctor_id}` (or a query param on the
existing case routes) that lists cases by `doctor_id`, backed by whatever
table `case/create` actually writes to (trace `companion_manager.create_case`
in `app/companion_api.py` to find it). More general-purpose than Option A,
but is new backend work someone needs to write and deploy.

Option A is less work and reuses infrastructure that already works
end-to-end; recommend it unless there's a reason the doctor app needs cases
independent of a Laravel appointment.

Once case_id is reachable, the doctor app's build-this-screen work is
standard: a case detail view calling `GET /api/companion/case/{case_id}`
through `AstraApiService`/`AstraGatewayClient` (already correctly
authenticated per branch in step 1), showing the AI companion's
journey/progress alongside the video-call entry point.

## 3. Trace doctor assignment at booking time - DONE

Traced end-to-end: `doctors_list.dart` fetches `Doctor` objects via
`RestClient(Apis.baseUrl).doctorList()`, and `Apis.baseUrl` is
`https://ayureze.org/api/` - Laravel, not Astra's own seed-data doctor
search. Tapping a card (`DoctorInfoCard_v2`) navigates to
`MakeAppointment(doctor: doctor)` with that same real `Doctor` object, and
`doctor.id` flows straight into `select_payment_methods.dart`
(`"doctor_id": details.doctor.id`, 3 call sites). Confirmed real, not
circumstantial: the doctor a patient books is always a genuine
Laravel-synced doctor, never Astra's test data.

## 4. Backend fix needed (not a client fix): `getLatestAstraFill` blocks doctors entirely - DONE

Fixed and deployed. Added `require_patient_or_doctor()` in
`app/security/auth/dependencies.py` and switched
`GET /api/v1/astra-fill/patient/{user_id}/latest` (`app/astra_fill/routes.py`)
to use it instead of `require_patient()`. Live on `astra.ayureze.in`.

Also found and fixed while wiring the doctor app's case list screen:
`astra_api_service.dart`'s `getLatestAstraFill()` was calling the wrong URL
entirely (`/astra-fill/latest/$id` instead of
`/astra-fill/patient/$id/latest`) - would have 404'd regardless of the
backend role fix above.

## 5. Wire FCM push registration in `docv1` - DONE

Added `AstraApiService.registerFcmTokenBestEffort()`, wired into both
doctor login completion paths (`SignInViewModel.saveUserData` and
`PhoneVerificationScreen._saveUserData`) as a fire-and-forget call.
Reuses the FCM token already cached for the main backend's push setup
(`Preferences.messageToken`) and resolves the doctor's Astra-format
`doctor_id` via `GET /api/v1/auth/user` rather than the Laravel numeric id.

Also found and fixed: `storeFcmToken()`'s request body didn't match the
backend's schema at all (`{token, user_id, user_type}` vs. the backend's
actual `{patient_id, fcm_token}` - `app/notification_routes.py`'s
`FCMTokenRequest`). Every call would have 422'd even before this was wired
up anywhere.

---

Suggested order: 0 → 1 → 4 (quick, backend-only, unblocks nothing else but
is a one-line fix) → 2 (the real remaining feature work) → 3 (a confirmation
pass, not a build) → 5 (small, independent, do whenever).

**Status: 2, 3, 4, 5 done.** Only 0 (which repo is canonical) and 1 (merging
the pending branches) remain, and both need a human decision - see each
section above for what's still open.
