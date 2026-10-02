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

## 2. Wire doctor-side case creation/receiving

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

## 3. Trace doctor assignment at booking time

Not fully traced during this audit. The patient app's booking screen
(`lib/v2/ui/appointment/select_payment_methods.dart`) already has a real
`doctor.id` by the time `linkAppointmentToAstra()` runs - it comes from
whatever doctor-selection screen led to booking
(`lib/v2/ui/appointment/make_appointment.dart` and upstream). That part is
fine; what's unverified is whether the *doctor list the patient picks from*
is guaranteed to be real, synced doctors (it should be, since that list
comes from Laravel directly, not Astra's own seed-data doctor-search
endpoint which we confirmed returns test data). Worth a quick confirmation
pass, not a rebuild.

## 4. Backend fix needed (not a client fix): `getLatestAstraFill` blocks doctors entirely

`GET /api/v1/astra-fill/patient/{user_id}/latest` requires
`Depends(require_patient())` - whose allowed roles are
`["patient", "admin", "superadmin"]`. A doctor's own JWT (`role: "doctor"`)
is not on that list, so **no doctor can ever call this successfully**,
authenticated or not. This is in `app/astra_fill/routes.py` on the real
backend. Fix is a one-line change: add `"doctor"` to whatever role list
backs that route (check `require_patient()`'s definition in
`app/security/auth/dependencies.py` and how the astra-fill routes use it -
might need a new `require_patient_or_doctor()` helper rather than loosening
`require_patient()` itself, to avoid accidentally widening other routes that
reuse it).

## 5. Wire FCM push registration in `docv1`

`AstraApiService.storeFcmToken()` exists (`lib/services/astra_api_service.dart`)
but is never called anywhere in the app - confirmed via grep, zero call
sites outside its own definition. Call it once, best-effort, right after
login succeeds (mirror the patient app's pattern:
`lib/features/astra/presentation/astra_chat_notifier.dart`'s `init()`,
which calls `storeFcmTokenWithGateway()` in a `try/catch` that only logs on
failure, never blocks). The doctor app's existing FCM token is likely
already fetched somewhere for the main Laravel backend's own push
notifications - reuse that same token value rather than requesting a new
one.

---

Suggested order: 0 → 1 → 4 (quick, backend-only, unblocks nothing else but
is a one-line fix) → 2 (the real remaining feature work) → 3 (a confirmation
pass, not a build) → 5 (small, independent, do whenever).
