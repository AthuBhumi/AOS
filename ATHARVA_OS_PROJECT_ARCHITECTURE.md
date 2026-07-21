# PROJECT SOFTWARE ARCHITECTURE SPECIFICATION
## PRODUCT: ATHARVA OS (iOS Native Application)
### Version: 1.0.0
### Date: July 21, 2026

---

## 1. Architectural Pattern & Design Justification

ATHARVA OS uses a **Clean Architecture** pattern combined with **MVVM-C (Model-View-ViewModel-Coordinator)**. This structure decouples presentation logic, domain business logic, and data storage operations, supporting offline-first synchronization and multi-agent AI execution.

```
[ PRESENTATION LAYER (SwiftUI / MVVM-C) ]
          │ (Uses)
          ▼
   [ DOMAIN LAYER (Use Cases / Entities) ]
          ▲ (Implements)
          │
     [ DATA LAYER (Repositories / SwiftData / Network) ]
```

### 1.1 Layer Separation
* **Presentation Layer**: 
  * Contains SwiftUI Views, ViewModels, and navigation Coordinators.
  * ViewModels expose screen state using the `Observable` framework and delegate user actions to Use Cases. Views do not query storage or network engines directly.
  * Navigation is managed by Coordinators to keep views reusable.
* **Domain Layer (Core)**:
  * The business core of the application. It contains structural business Entities (e.g., `User`, `FocusSession`, `Workout`) and functional Use Cases.
  * Use Cases orchestrate business rules (e.g., `StartFocusBlockUseCase`, `LogGymSetUseCase`, `CalculateRunwayUseCase`).
  * This layer has no dependencies on database libraries, network clients, or UI frameworks.
* **Data Layer**:
  * Implements domain Repository interfaces.
  * Manages the data lifecycle, orchestrating SwiftData context modifications, local SQLCipher disk queries, Keychain access, and API operations.

---

## 2. Dependency Injection (DI) Strategy

To maintain modular boundaries, dependency injection is resolved using a **Compile-Time Safe DI Container** pattern:
* **Scopes**:
  * **Singleton**: Shared global instances initialized at launch (e.g., `NetworkClient`, `DatabaseContainer`, `SyncEngine`).
  * **Transient**: Short-lived instances created on demand (e.g., ViewModels, Use Cases, Coordinators).
* **Implementation Protocol**:
  * Components declare dependencies via protocol interfaces.
  * Dependencies are injected using initializer parameters, allowing easy swapping of live implementations with mock interfaces during unit testing.

---

## 3. Modular Folder Structure & Package Separation

The codebase is organized into modular packages to isolate dependencies and prevent circular reference imports:

```
[ App Root Target ]
 ├── Core/
 ├── Common/
 ├── DesignSystem/
 ├── Theme/
 ├── Assets/
 ├── Localization/
 ├── Feature Modules (Authentication, Dashboard, DailyMission, AI, Coding, etc.)
 ├── Repositories/
 ├── Services/
 ├── Models/
 └── Platforms/
```

### 3.1 Core Packages

#### Core/ (Foundation Module)
* **Purpose**: Core platform dependencies.
* **Responsibilities**: Custom operators, runtime configurations, base protocols.
* **Dependencies**: None.

#### Common/
* **Purpose**: Shared utilities used across feature modules.
* **Responsibilities**: Date formatting helpers, string extensions, custom calculations.
* **Dependencies**: None.

#### DesignSystem/
* **Purpose**: UI component framework.
* **Responsibilities**: Implements layout tokens, typography models, and squircle card layouts.
* **Dependencies**: `Assets/`, `Theme/`.
* **Reusable Components**: `VibrantCard`, `PrimaryActionButton`, `MetricLabel`.

#### Theme/
* **Purpose**: Color palettes.
* **Responsibilities**: Defines dark/light mode configurations and color tokens.
* **Dependencies**: None.

#### Assets/
* **Purpose**: Graphic assets.
* **Responsibilities**: Handles image catalogs and branding resources.
* **Dependencies**: None.

#### Localization/
* **Purpose**: Text localization.
* **Responsibilities**: Localizes strings (English, Spanish, etc.).
* **Dependencies**: None.

---

### 3.2 Feature Modules

#### Authentication/
* **Purpose**: Handles signup, login, and profile setup.
* **Dependencies**: `DesignSystem/`, `Networking/`, `Security/`.
* **Reusable Components**: `PasscodeInputField`, `FaceIDButton`.

#### Dashboard/
* **Purpose**: Renders dynamic stage workspaces.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Models/`.
* **Reusable Components**: `MissionWidget`, `TISChartCard`.

#### DailyMission/
* **Purpose**: Daily checklist operations.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `ChecklistRow`.

#### AI/
* **Purpose**: Interfaces with the AI Advisor board.
* **Dependencies**: `DesignSystem/`, `Networking/`, `Storage/`, `Models/`.
* **Reusable Components**: `ChatBubbleView`, `VoiceRecordingIndicator`.

#### Coding/ (Java & DSA Module)
* **Purpose**: Educational modules, code sandbox, and typing exercises.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Common/`, `Models/`.
* **Reusable Components**: `CodeTextEditorView`, `RoadmapTreeView`.

#### Projects/
* **Purpose**: Task delegation and project tracking.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `KanbanColumnView`.

#### Reading/ (Books Module)
* **Purpose**: Reading logs and active recall flashcards.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `FlashcardFlipView`.

#### Journal/ (Mood Module)
* **Purpose**: Journaling text editor and mood log coordinates.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Common/`.
* **Reusable Components**: `MoodCircumplexSelector`.

#### Habits/ (Goals Module)
* **Purpose**: Habits checklists and OKR maps.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `StreakRingView`.

#### VisionBoard/
* **Purpose**: Visualization matrices.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `SquirclePhotoGrid`.

#### Finance/ (Savings & Investment Module)
* **Purpose**: Expense ledgers, savings goals, and investment assets.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Networking/`.
* **Reusable Components**: `RunwayGaugeView`, `TransactionRow`.

#### Business/ (Startup & Company Module)
* **Purpose**: Lean Canvas editor and cap table calculator.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `CapTableDilutionChart`.

#### CEO/
* **Purpose**: Strategic metrics dashboard.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Finance/`, `Business/`.
* **Reusable Components**: `CompanyHealthMeter`.

#### Gym/ (Health, Sleep, Water, Nutrition Modules)
* **Purpose**: Gym logs, sleep trackers, water, and nutrition metrics.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Health/`.
* **Reusable Components**: `WorkoutSetRow`, `CalorieProgressRing`.

#### Calendar/ (Meetings Module)
* **Purpose**: Schedule grid and meeting cost calculators.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `TimelineBlockView`.

#### Notifications/
* **Purpose**: APNS routing interface.
* **Dependencies**: `Core/`.
* **Reusable Components**: `NotificationPreferencesRow`.

#### Analytics/ (Reports Module)
* **Purpose**: Dynamic reporting and scatterplot graphs.
* **Dependencies**: `DesignSystem/`, `Storage/`.
* **Reusable Components**: `PearsonCorrelationChart`.

#### VoiceNotes/ (Documents Module)
* **Purpose**: Encrypted audio logs and PDF vaults.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Security/`.
* **Reusable Components**: `AudioVisualizerView`, `PDFDocRow`.

#### Settings/ (Backup & CloudSync Modules)
* **Purpose**: User configuration panels.
* **Dependencies**: `DesignSystem/`, `Storage/`, `Security/`, `Cloud/`.
* **Reusable Components**: `SettingsToggleRow`.

---

### 3.3 Infrastructure Packages

#### Repositories/
* **Purpose**: Relational database operations.
* **Responsibilities**: Fetches, writes, and deletes SQLite records via SwiftData.
* **Dependencies**: `Storage/`, `Models/`.

#### Services/
* **Purpose**: External system APIs integration.
* **Responsibilities**: Integrates with external systems (HealthKit, Plaid, AI engines).
* **Dependencies**: `Networking/`, `Security/`.

#### Models/
* **Purpose**: App entities database schemas.
* **Responsibilities**: Defines models matching database tables.
* **Dependencies**: None.

#### Networking/
* **Purpose**: API gateway client.
* **Responsibilities**: Handles HTTP requests, response parsing, and token refresh.
* **Dependencies**: `Common/`, `Security/`.

#### Storage/
* **Purpose**: SwiftData container setup.
* **Responsibilities**: Manages SQLite files and database schemas.
* **Dependencies**: `Models/`.

#### Security/
* **Purpose**: Encryption and biometric checks.
* **Responsibilities**: Encrypts files, derives keys, and manages Keychain.
* **Dependencies**: None.

#### Logging/
* **Purpose**: System diagnostics.
* **Responsibilities**: Writes structured logs to console and database.
* **Dependencies**: None.

#### Testing/
* **Purpose**: Mock data structures for tests.
* **Dependencies**: `Models/`, `Repositories/`.

---

## 4. Module Design & Lifecycle

Every module acts as a self-contained framework target:
* **Public Interfaces**: Exposed using explicit `public` classes and protocols. Core dependencies are hid behind interface contracts, preventing internal implementations from leaking into referencing feature targets.
* **Initialization Flow**:
  1. The app starts and runs the `CoreContainer` initializer.
  2. Services are registered with the DI Container.
  3. Feature coordinators initialize view models, injecting required repositories.
  4. The View layer loads, reading states from injected ViewModels.
* **Module Communication**: Features communicate asynchronously using the **Coordinator Delegate** pattern to prevent tight coupling between screens.

---

## 5. State Management Architecture

State is managed at different levels of scope using Apple's `Observable` framework:

```
[ GlobalAppState ] ──► Stores logged-in user profiles, network state
        │
        ├── [ ModuleState ] ──► Active workout logs, compile tasks
        │
        └── [ ScreenState ] ──► View scrolling states, input focuses
```

* **Global State**:
  * Pinned as a environment object at the root of the app.
  * Contains the active user session model, network state, and sync status.
* **Module State**:
  * Tracks feature-specific operations (e.g., active sets inside a workout session).
* **Screen State**:
  * Isolated to individual view models, tracking view-specific properties like search queries or loading states.
* **Offline Sync State**:
  * Coordinates changes in the database, updating sync indicators when transactions are queued.

---

## 6. Network Layer Specification

The network layer handles API Gateway communication:
* **API Client**: Implements standard HTTP requests using `URLSession`.
* **Authentication Interceptor**:
  * Inspects outgoing requests and appends the user's active `Authorization: Bearer <token>` header.
  * If a request returns a `401 Unauthorized` status:
    * Suspends the request queue.
    * Calls `/v1/auth/refresh` to get a new access token.
    * Updates the Authorization headers and retries the failed requests.
* **Retry Strategy**:
  * Failed calls due to network loss employ an exponential backoff retry logic:
    $$T_{\text{wait}} = 2^{\text{attempt}} \times 1.0\text{ second} + \text{random\_jitter}$$
  * Rate-limited requests (`429 Too Many Requests`) check the `Retry-After` header before retrying.

---

## 7. Storage Subsystems

* **Local Database**:
  * Implemented using **SwiftData** layered over **SQLite**. The context is initialized with SQLCipher active.
* **Secure Storage**:
  * Critical assets (passwords, tokens, database encryption keys) are saved in the iOS **Keychain** using security flags that require biometric verification to read.
* **Temporary Cache**:
  * Standard data caches are kept in `Library/Caches/` to allow the iOS system to clean up disk space when the device is running out of storage.

---

## 8. Services Architecture

```
[ Application Service Locator ]
 ├── AuthenticationService -- Handles login & biometrics keys
 ├── AIService             -- Orchestrates prompt RAGs & streams
 ├── HealthService         -- Queries sleep stages from HealthKit
 └── SyncService           -- Resolves vector clock syncs
```

* **Sync Service**:
  * Coordinates data synchronization. Queries the local `sync_queue` table, uploads modifications, and writes server changes back to SwiftData.
* **AI Service**:
  * Directs communications with LLM proxies. Integrates SSE streams with client view models.
* **Health Service**:
  * Interfaces with Apple **HealthKit**, querying sleep stage intervals and active calories.

---

## 9. Cryptographic Security Framework

* **Key Management Strategy**:
  * Derived keys are stored in the Keychain using the `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` protection class, preventing transfer to other devices via iCloud backups.
* **Transport Integrity**:
  * Employs **SSL Certificate Pinning** on remote backend requests to protect against Man-in-the-Middle (MITM) attacks.
* **Biometric Auth Integration**:
  * Authentication workflows use `LAContext` APIs to verify biometrics. If FaceID fails, the app falls back to a custom, biometric-backed 6-digit passcode sheet.

---

## 10. Application Logging & Performance Diagnostics

* **Structured Logging**:
  * Uses Apple's native `os.Logger` framework.
  * Logs are categorized by subsystem (e.g., `com.atharva.os.networking`, `com.atharva.os.storage`) and priority level (debug, info, error, fault).
* **Performance Monitoring**:
  * Implements `OSSignpost` indicators to track resource usage (like launch speed and database query latency), outputting traces during performance tests.

---

## 11. Testing Architecture

```
[ Verification Matrix ]
 ├── Unit Tests        -- Focus: Use cases, entity rules (Target: >85% coverage)
 ├── Integration Tests -- Focus: SwiftData context operations, API syncs
 └── UI Automated      -- Focus: User paths (Login, Sandbox execution)
```

* **Unit Tests**:
  * Targets domain use cases. Mock repositories are injected to isolate database and network operations.
* **Security & Performance Tests**:
  * Measures database read/write speeds, memory allocations under ProMotion, and verifies Keychain encryption keys are inaccessible when the device is locked.

---

## 12. Environment & Secrets Configurations

* **Target Profiles**:
  * Configures four distinct build configurations: `Development`, `Testing`, `Staging`, and `Production`.
* **Configurations Mapping**:
  * Environment variables (like API hosts and sync identifiers) are managed using `.xcconfig` files.
* **Secrets Management**:
  * Secure API keys and production keys are excluded from the repository. They are injected at build time from CI/CD vault parameters.

---

## 13. Build & Release Strategy

* **Git Flow Protocol**:
  * Feature branches merge into `develop`. Release targets are branched off `develop` to `release/vX.Y.Z` for App Store submission, before being merged into `main`.
* **Feature Flags**:
  * Beta features are wrapped in feature flags (e.g., `AOSFeatureFlags.isPlaidSyncEnabled`), allowing them to be toggled remotely without requiring an App Store update.
* **Rollback Protocol**:
  * In case of critical production issues, the deployment pipeline can trigger a hotfix release, reverting features to the last stable build configuration within 2 hours.

---

## 14. Cross-Platform Scalability Map

* **iPadOS Adaptations**:
  * Layout containers use `NavigationSplitView` to support multi-column layouts on larger screens.
* **watchOS Companion Architecture**:
  * Communicates with the iOS app using Apple's `WatchConnectivity` framework, sending lightweight transaction dictionaries to the primary database context.
* **Web Dashboard Bridge**:
  * The backend provides REST endpoints that map directly to the mobile database structure, allowing the future web dashboard to sync changes using the same API payload schemas.

---

## 15. Architectural Verification Checklist

Before starting implementation, development teams must verify:
* [ ] No circular imports exist between feature packages.
* [ ] All network operations utilize the token refresh interceptor.
* [ ] All database entities implement the sync protocols.
* [ ] Sensitive fields are flagged for client-side encryption before SQLite disk writes.
* [ ] All touch target controls satisfy HIG size guidelines.
