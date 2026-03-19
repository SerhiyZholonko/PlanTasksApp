# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build for simulator
xcodebuild -project PlanTasks.xcodeproj -scheme PlanTasks -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -project PlanTasks.xcodeproj -scheme PlanTasks -destination 'platform=iOS Simulator,name=iPhone 15'
```

No CocoaPods — use `.xcodeproj` directly with SPM packages.

## Architecture

MVVM with Factory dependency injection, organized in three layers:

**Presentation** (`Core/`) — SwiftUI views + `@MainActor`-isolated `ObservableObject` ViewModels. Each ViewModel conforms to `ErrorDisplayable` and/or `AlertDisplayable` protocols, and exposes `error: Error?` / `alert: AppAlert?` which views bind to via `.showError(item:)` / `.showAlert(item:)` view modifiers. Async operations are wrapped with `Task(handlingError: self) { ... }` which auto-assigns thrown errors to `self.error`.

**Domain** (`Domain/`) — Plain Swift models (`AppUser`, `User`, `PTask`, `Home`, `AppAlert`, `AppError`, `AppState`, `AuthType`) and protocols (`DataStoreProtocol`, `AuthStoreProtocol`, `ErrorDisplayable`, `AlertDisplayable`).

**Data** (`Stores/`) — Two protocol abstractions:
- `DataStoreProtocol` — CRUD for `User` and `PTask`. `MockDataStore` uses in-memory arrays (pre-populated with 5 Ukrainian-named users/tasks). `LocalDataStore` persists Users to UserDefaults (key `"Home_storage"`); Tasks are in-memory only.
- `AuthStoreProtocol` — `signIn`, `signUp`, `signOut`, and a `currentUserPublisher: AnyPublisher<AppUser?, Never>`. `FirebaseAuthStore` is the live implementation (uses Firebase Auth state listener). `MockAuthStore` is for previews/tests.

### DI

Factory container is extended in `Extensions/Container+Registration.swift`. Currently:
- `authStore` → `FirebaseAuthStore` (singleton)
- `dataStore` → `MockDataStore` (singleton)

To swap implementations change the factory closures here. In SwiftUI Previews use `.injectMockData()` view modifier.

### Navigation

Root navigation is state-driven via `AppState` enum (`.auth` | `.home`) held in `AppStartingViewModel`, which subscribes to `authStore.currentUserPublisher` — if a user is emitted it transitions to `.home`, otherwise `.auth`. `HomeView` uses `NavigationStack` internally with a toolbar `NavigationLink` to `ProfileView`. Modals (AddTaskView, MessageView, SettingsView) are rendered as overlays with `matchedGeometryEffect` animations driven by booleans on `HomeViewModel`.

### Color System

All semantic colors are defined in `Colors.xcassets` and accessed via `Color.appTheme` (returns `AppColorTheme` struct with 18 named slots: `accent`, `text`, `secondaryText`, `viewBackground`, `cellBackground`, `primaryAction`, `destructive`, `success`, `warning`, `error`, `inProgress`, etc.). Never use raw color literals — always use `Color.appTheme.*`.

## Key Dependencies (SPM)

- **Factory 2.5.3** — DI container (`@Injected(\.dataStore)`, `@Injected(\.authStore)`)
- **Firebase 12.10.0** — FirebaseCore, FirebaseAuth, FirebaseFirestore, FirebaseDatabase, FirebaseAnalytics

## Auth Methods

`AuthStoreProtocol` defines four sign-in methods, all implemented in `FirebaseAuthStore`:

- **Email/password** — `signIn` / `signUp` (with display name commit via `createProfileChangeRequest`)
- **Google** — `signInWithGoogle()` uses `GIDSignIn.sharedInstance.signIn(withPresenting:)` then exchanges the ID token for a Firebase credential
- **Apple** — `signInWithApple(idToken:rawNonce:fullName:)` called from `AuthViewModel` after `ASAuthorizationAppleIDRequest` nonce setup (SHA-256 hashed)
- **Phone** — two-step: `sendPhoneVerification(phoneNumber:)` → `signInWithPhone(verificationID:code:)`. Uses `PhoneAuthUIDelegate` (internal) as reCAPTCHA fallback when APNs are unavailable. UI state is tracked via `PhoneAuthStep` enum (`.enterPhone` / `.enterCode(verificationID:)`).

`MockAuthStore` stubs all methods for SwiftUI Previews.

## Firestore Structure

```
registeredUsers/{uid}          ← written on every sign-in; used for employee search
  id, name, email, phoneNumber, avatarInitials

users/{uid}/employees/{empId}  ← current user's added employees
  id, name, email, phoneNumber, avatarInitials
```

`FirebaseDataStore` (active via DI) implements `DataStoreProtocol`:
- `getAllUsers()` / `addUser` / `deleteUser` → `users/{uid}/employees` subcollection
- `searchRegisteredUsers(query:)` → loads all `registeredUsers/`, filters client-side, excludes self and already-added
- Tasks remain in-memory (Firestore tasks wiring TBD)

`FirebaseAuthStore.saveRegisteredUser(_:)` is called after every successful sign-in (Google, Apple, Phone) and after `updateDisplayName` — keeps `registeredUsers/{uid}` up to date.

`User.id` is a `String` (Firebase UID). `MockDataStore` uses `UUID().uuidString` for previews/tests.
