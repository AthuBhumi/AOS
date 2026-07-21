# UI BIBLE & DESIGN SPECIFICATIONS
## PRODUCT: ATHARVA OS (iOS Native Application)
### Version: 1.0.0
### Date: July 21, 2026

---

## 1. Introduction & Design Philosophy

This UI Bible defines the interface structure, interaction rules, and responsive behaviors of the **ATHARVA OS** application. It serves as an actionable design blueprint for UI designers and iOS development teams.

All screen layouts utilize design tokens defined in [ATHARVA_OS_DESIGN_SYSTEM.md](file:///e:/Origin%20Platforms/Projects/AOS/ATHARVA_OS_DESIGN_SYSTEM.md) and execute data structures specified in [ATHARVA_OS_DB_ARCHITECTURE.md](file:///e:/Origin%20Platforms/Projects/AOS/ATHARVA_OS_DB_ARCHITECTURE.md).

---

## 2. Authentication & Core Entry Module

### 2.1 Screen: Splash
* **Purpose**: System initialization, database validation, and biometric authentication launch.
* **Layout Structure**: 
  * Full-screen black background (`Hex #000000`).
  * Centered brand logo ($120\text{pt} \times 120\text{pt}$) featuring a dynamic shimmer border.
  * Inline loading text (`font_footnote` in `Secondary Gray`) positioned $44\text{pt}$ above the bottom safe area.
* **Header Design**: Clean canvas. No title or action buttons.
* **Navigation Entry**: App execution launch.
* **Navigation Exit**: 
  * If new user: Route to **Onboarding Diagnostic**.
  * If authenticated user: Route to FaceID authentication loop. If successful, route to **Dynamic Dashboard**.
* **Button Specification**:
  * *Tap Brand Logo*: Retry FaceID authentication. Animation: Soft scale pulse ($1.05\times$).
* **Animations**:
  * Shimmer outline gradient sweeps border left-to-right ($1.2\text{s}$ duration, infinite loop).
  * On transition exit, the brand logo scales down to $0.80\times$ and fades to $0.0$ opacity over $0.4\text{s}$.
* **Offline Behavior**: Fully operational offline. Loads local database parameters.

### 2.2 Screen: Onboarding Diagnostic
* **Purpose**: Questionnaire survey mapping user habits to career stages.
* **Layout Structure**:
  * Pinned header showing a pagination indicator (e.g., "3 of 15").
  * Multi-choice survey questions presented as a stacked card deck.
  * Bottom drawer navigation buttons.
* **Form Fields**:
  * *Survey Question Option*: Radio button selector cards. Tap modifies active context variables.
* **Button Specification**:
  * *Next Button*: 
    * Purpose: Increment survey page. Action: Validates that an option has been selected, then transitions to the next question card. Animation: Slide card right-to-left.
* **Animations**:
  * Slider animation: Cards slide out left and slide in right using a spring transition (`spring(response: 0.38, dampingFraction: 0.8)`).
* **Validation Rules**:
  * Users cannot tap "Next" until one option checkbox is selected.

### 2.3 Screen: Login
* **Purpose**: User account authentication.
* **Layout Structure**:
  * Centered logo widget, followed by linear text inputs.
  * Bottom stacked buttons (Login, Forgot Password, Sign Up).
* **Form Fields**:
  * *Email Input*: Keyboard: `emailAddress`, Placeholder: "name@domain.com", Required.
  * *Password Input*: Keyboard: `asciiCapable`, Secure entry active, Required.
* **Button Specification**:
  * *Login Button*: 
    * Action: Submits credentials to validation pipeline. If successful, routes to Dynamic Dashboard. Validation: Email regex check, password length $\ge 8$. Animation: Shrink and spinner overlay.
  * *Forgot Password Button*:
    * Action: Opens password reset modal sheet.

### 2.4 Screen: Signup
* **Purpose**: Account registration.
* **Layout Structure**:
  * Scrollable linear list containing registration forms.
  * Bottom agreement disclaimer checkbox text.
* **Form Fields**:
  * *Full Name*: Keyboard: `default`, Placeholder: "Atharva Dev", Required.
  * *Email*: Keyboard: `emailAddress`, Placeholder: "name@domain.com", Required.
  * *Password*: Keyboard: `asciiCapable`, Secure, Required.
* **Button Specification**:
  * *Register Button*: Validates inputs, creates user record, and routes to Profile Setup.

### 2.5 Screen: Forgot Password
* **Purpose**: Recover account password via email link.
* **Layout Structure**:
  * Centered lock graphic, text details, and input form.
* **Form Fields**:
  * *Email Input*: Keyboard: `emailAddress`, Placeholder: "name@domain.com", Required.
* **Button Specification**:
  * *Send Recovery Email*: Sends reset payload, displays confirmation dialog, and routes back to Login.

### 2.6 Screen: Profile Setup
* **Purpose**: Profile configuration on first login.
* **Layout Structure**:
  * Centered photo selector circle, followed by display name forms.
* **Form Fields**:
  * *Display Name*: Keyboard: `default`, Placeholder: "Rohan", Required.
* **Button Specification**:
  * *Complete Profile Setup*: Saves profile metadata, routes to notifications configurations.

### 2.7 Screen: Notifications Setup
* **Purpose**: Setting up system notification permissions.
* **Layout Structure**:
  * Detailed lists explaining alert categories (Discipline, Finance, AI).
  * Prominent permissions activation card.
* **Button Specification**:
  * *Enable Notifications*: Triggers native iOS UNNotificationRequest prompt.

---

## 3. Dynamic Workspaces & Core Disciplines

### 3.1 Screen: Dynamic Dashboard
* **Purpose**: Stage-specific dynamic landing panel.
* **Layout Structure**:
  * Dynamic header updating display based on Time of Day, Weather, and TIS levels.
  * Active Stage checklist (Stage 1 habits / Stage 2 coding / Stage 3 speech / Stage 4 OKRs).
* **Card Specifications**:
  * *Stage 1 Checklist Card*: Left-swipe checkboxes, registers XP rewards.
  * *Stage 4 CEO Widget Card*: Displays business runway progress metrics and HealthIndex.
* **Gestures**:
  * Pull-down from top header triggers Global Search Spotlight.
  * Swipe left-to-right between cards swaps detail workspaces.

### 3.2 Screen: Today's Mission
* **Purpose**: Checklist representing non-negotiable daily objectives.
* **Layout Structure**:
  * Linear scroll list of daily task cards.
  * Bottom progress bar showing percentage completion.
* **Button Specification**:
  * *Claim Rewards Button*: Inactive by default. Active when all mission cards are checked. Action: Adds +150 XP.

### 3.3 Screen: Daily Planner
* **Purpose**: Time-blocking schedule compiler.
* **Layout Structure**:
  * 24-hour horizontal scrolling timeline.
  * List of tasks categorized using the Eisenhower Matrix.
* **Button Specification**:
  * *Initiate Focus Block*:
    * Purpose: Start Focus block timer. Destination: Modal focus mode lock. Animation: Dynamic Island expansion transition.

### 3.4 Screen: Habits View
* **Purpose**: Long-term habits directory.
* **Layout Structure**:
  * Grid layout of habit cards.
* **Card Specifications**:
  * *Habit Item Card*: Displays title, weekly dot compliance rings, and streak numbers. Tap: Open details sheet.

### 3.5 Screen: Habit Details
* **Purpose**: Habit cue-crave-reward setup and streak analysis charts.
* **Charts**:
  * *Compliance Bar Chart*: Type: Bar, Data source: `habit_streaks` records, Update: Daily check-in.
* **Form Fields**:
  * *Cue field*: Placeholder: "After I drink my morning coffee...", Optional.
  * *Reward field*: Placeholder: "Claiming +10 XP...", Optional.

### 3.6 Screen: Goals Map
* **Purpose**: Tracks long-term life milestones.
* **Layout Structure**:
  * Three-column layout mapping: Life (10-yr), Milestones (3-yr), and OKRs (Annual).
* **Button Specification**:
  * *Add Objective*: Opens bottom sheet form editor.

### 3.7 Screen: Goal Details
* **Purpose**: Details progress on linked Key Results.
* **Progress Indicators**:
  * Radial progress ring showing overall percentage completion of nested objectives.

### 3.8 Screen: Vision Board
* **Purpose**: Visual asset display representing future aspirations.
* **Layout Structure**:
  * 3x3 photo collage matrix.
* **Card Specifications**:
  * *Vision Image Card*: Long press: Edit caption prompt. Double-tap: Zoom transition.

### 3.9 Screen: Calendar
* **Purpose**: Aggregates external and internal calendar blocks.
* **Layout Structure**:
  * Pinned monthly grid container at the top, vertical agenda list at the bottom.

### 3.10 Screen: Meetings Planner
* **Purpose**: Meeting scheduler featuring resource cost calculation.
* **Form Fields**:
  * *Attendees Count*: Keyboard: `numberPad`, Placeholder: "2", Required.
  * *Duration*: Dropdown picker (30m, 45m, 60m).
* **Calculations**:
  * Dynamic inline text displays: "Estimated Meeting Cost: \$300/hr."

---

## 4. AI Mentor Advisory Module

### 4.1 Screen: AI Mentor
* **Purpose**: Dashboard showing active virtual board advisors (CTO, CFO, CMO, Coach).
* **Layout Structure**:
  * Row layout showing advisor avatar cards.
  * Recent consultation message listings.
* **Card Specifications**:
  * *Advisor Avatar Card*: Tap: Opens SCR-10 Chat thread. Long press: Reset advisor memory logs.

### 4.2 Screen: AI Chat
* **Purpose**: Group conversation panel with advisors.
* **Layout Structure**:
  * Vertical scroll chat workspace.
  * Bottom floating message text editor.
* **Form Fields**:
  * *Chat Input Box*: Keyboard: `default`, Placeholder: "Consult the Board...", Required.
* **Gestures**:
  * Swipe-left on chat bubble: Opens context citation sources.

### 4.3 Screen: Voice Notes
* **Purpose**: Voice recordings audio dictation and sorting.
* **Layout Structure**:
  * Circular waveform graphic displaying voice capture metrics.
* **Button Specification**:
  * *Record Button*: Triggers microphone access, starts recording loop.

---

## 5. Academy & Technical Mastery Module

### 5.1 Screen: Coding Dashboard
* **Purpose**: Stage 2 landing showing developer progress levels.
* **Layout Structure**:
  * Header showing WPM speed stats, DSA solutions count, and active Java roadmaps.
  * Linear lists for next academy modules.

### 5.2 Screen: Learning Roadmap
* **Purpose**: Vector maps displaying study modules.
* **Layout Structure**:
  * Node branching curriculum tree drawing.
* **Card Specifications**:
  * *Roadmap Node Card*: Locked status disables selection. Unlocked node opens SCR-15 details sheet.

### 5.3 Screen: Java Learning
* **Purpose**: Text modules for Java study chapters.
* **Layout Structure**:
  * Scrollable reader panel.
* **Button Specification**:
  * *Create Recall Flashcards*: Generates Anki-styled card configurations.

### 5.4 Screen: DSA Learning
* **Purpose**: Reference directory of computer science algorithms.
* **Layout Structure**:
  * Filter chips: "Arrays", "Graphs", "Trees", "Sorting".

### 5.5 Screen: Topic Details
* **Purpose**: Technical details sheet for algorithmic structures.
* **Layout Structure**:
  * Split-screen layout. Top: Theory text details. Bottom: Boilerplate preview card.

### 5.6 Screen: Practice Problems Sandbox
* **Purpose**: On-device syntax compilation sandbox.
* **Layout Structure**:
  * Full-screen code text editor, with vertical code run consoles drawer at the bottom.
* **Form Fields**:
  * *Compiler Input*: Keyboard: `asciiCapable`, Font: `SF Mono`, Required.
* **Button Specification**:
  * *Execute Code*: Submits code block to parsing engine.

### 5.7 Screen: Quiz
* **Purpose**: Multiple-choice assessments for syntax reviews.
* **Layout Structure**:
  * Centered card showing active quiz questions.
  * Multi-choice selection rows.

### 5.8 Screen: Coding Progress
* **Purpose**: Line graph representations of compiler score milestones.
* **Charts**:
  * *Performance Line Chart*: Type: Line, Data source: `dsa_submissions` records.

### 5.9 Screen: Typing Practice
* **Purpose**: Writing exercise tracks keystroke speeds and error indicators.
* **Layout Structure**:
  * Target string deck, active cursor marker, keyboard layout overlays.
* **Gestures**:
  * Physical keyboard key-stroke listeners.

### 5.10 Screen: Communication Practice
* **Purpose**: Email text editing drill scenarios.
* **Layout Structure**:
  * Top card: Negotiation scenario details. Bottom: Form input boxes.
* **Form Fields**:
  * *Email Text Editor*: Keyboard: `default`, Placeholder: "Write response...", Required.

### 5.11 Screen: Interview Practice
* **Purpose**: Conversational interview simulation.
* **Layout Structure**:
  * Advisor chat box on top, user response record actions at the bottom.

---

## 6. Personal Health & Life Tracking Module

### 6.1 Screen: Health Dashboard
* **Purpose**: Aggregates gym tracker logs and sleep calculations.
* **Layout Structure**:
  * 2x2 grid containing metrics for sleep hours, steps, and gym workout completions.

### 6.2 Screen: Sleep
* **Purpose**: Sleep debt analysis charts.
* **Charts**:
  * *Sleep Debt Chart*: Type: Bar, Data source: Apple HealthKit sleep records, Update: Daily, Animation: Fill bar height.

### 6.3 Screen: Workout Dashboard
* **Purpose**: Routine planner and progressive weight tracking.
* **Layout Structure**:
  * Vertical list showing saved routine cards (Push/Pull split configs).

### 6.4 Screen: Workout Session
* **Purpose**: Live logger for exercises, weights, and repetitions.
* **Layout Structure**:
  * Header timer counting active session time.
  * Nested exercise tables with input forms.
* **Form Fields**:
  * *Weight Input*: Keyboard: `decimalPad`, Placeholder: "185", Required.
  * *Reps Input*: Keyboard: `numberPad`, Placeholder: "8", Required.

### 6.5 Screen: Exercise Detail
* **Purpose**: Historical set logs for a selected exercise.
* **Charts**:
  * *1RM Progress Chart*: Type: Line, Data source: `gym_sets` history.

### 6.6 Screen: Nutrition
* **Purpose**: Macros and caloric balance entries.
* **Form Fields**:
  * *Protein Input*: Keyboard: `numberPad`, Placeholder: "150g", Required.

### 6.7 Screen: Water
* **Purpose**: Tracks water intake volume metrics.
* **Button Specification**:
  * *Log 250ml Button*: Increments active intake values. Animation: Wave fill.

### 6.8 Screen: Books
* **Purpose**: Reading library catalog tracker.
* **Layout Structure**:
  * Book covers grid view.

### 6.9 Screen: Book Details
* **Purpose**: Active recall setup configuration for chapters.
* **Button Specification**:
  * *Log Chapters Read*: Opens recall quiz cards modal sheet.

### 6.10 Screen: Reading Progress
* **Purpose**: Active recall flashcard reviewer.
* **Card Specifications**:
  * *Flashcard Review Card*: Tap: Flip card to reveal answer. Swipe-left: Mark as failed. Swipe-right: Mark as passed.

---

## 7. Finance & Wealth Allocation Module

### 7.1 Screen: Finance Dashboard
* **Purpose**: Net worth indicator summaries.
* **Layout Structure**:
  * Top: Large net worth metric banner ($36\text{pt}$ semibold font).
  * Mid: Plaid sync transaction ledgers.
  * Bottom: Savings goals progress cards.

### 7.2 Screen: Expense Entry
* **Purpose**: Manual transaction entries ledger.
* **Form Fields**:
  * *Amount Input*: Keyboard: `decimalPad`, Placeholder: "-1200.00", Required.
  * *Category Selection*: Dropdown list, Required.

### 7.3 Screen: Savings
* **Purpose**: Target runway planning.
* **Calculations**:
  * Dynamic text outputs survival runway metrics in months based on expense ledgers.

### 7.4 Screen: Salary
* **Purpose**: Logging recurring incomes.
* **Form Fields**:
  * *Paycheck Amount*: Keyboard: `decimalPad`, Placeholder: "5000.00", Required.

### 7.5 Screen: Investments
* **Purpose**: Asset allocation allocations.
* **Charts**:
  * *Asset Allocation Chart*: Type: Pie, Data source: `investment_portfolios` records.

### 7.6 Screen: Net Worth
* **Purpose**: Assets vs liabilities trend calculations.
* **Charts**:
  * *Net Worth Trend Chart*: Type: Line, Data source: Combined financial records.

---

## 8. Startup & Corporate Scaling Module

### 8.1 Screen: Business Dashboard
* **Purpose**: Corporate metrics overview.
* **Layout Structure**:
  * Active runway indicators, client counts, project timelines.

### 8.2 Screen: Startup Planner
* **Purpose**: 9-box Lean Canvas compiler.
* **Layout Structure**:
  * Interactive grid segments. Tapping expands editor forms.

### 8.3 Screen: Company Planner
* **Purpose**: Option pools and cap table simulators.
* **Form Fields**:
  * *Equity Shareholder Name*: Keyboard: `default`, Placeholder: "Co-Founder Name", Required.
  * *Shares Allotted*: Keyboard: `numberPad`, Placeholder: "100000", Required.

### 8.4 Screen: Clients
* **Purpose**: Client directory.
* **Layout Structure**:
  * Linear scroll list of client contact profiles.

### 8.5 Screen: Projects
* **Purpose**: Task delegation map.
* **Layout Structure**:
  * Kanban board columns.

### 8.6 Screen: CEO Dashboard
* **Purpose**: High-level OKR maps and runway warnings.
* **Layout Structure**:
  * Pinned runway status cards. Warns red when runway is under 3 months.

---

## 9. Vault, Analytics & Settings Module

### 9.1 Screen: Weekly Review
* **Purpose**: Weekly correlation calculations of discipline vs business parameters.
* **Button Specification**:
  * *Export PDF Report*: Action: Packages weekly data into styled PDF.

### 9.2 Screen: Analytics Dashboard
* **Purpose**: Cross-domain scatterplot comparison views.
* **Charts**:
  * *Analytics Scatterplot*: Type: Scatterplot, Data source: Correlation records.

### 9.3 Screen: Achievements
* **Purpose**: Locked/unlocked performance badges index.
* **Layout Structure**:
  * Hexagonal badge gallery grid.

### 9.4 Screen: XP
* **Purpose**: Stats attribute updates tracking.
* **Layout Structure**:
  * Character stats matrix showing levels and experience details.

### 9.5 Screen: Leaderboard
* **Purpose**: Global user ranking leagues.
* **Layout Structure**:
  * Paged scroll table of ranked user profiles.

### 9.6 Screen: Documents
* **Purpose**: Secure locked file viewer within the vault.
* **Layout Structure**:
  * Folder directories list. Needs biometric clearance to unlock.

### 9.7 Screen: Secure Vault
* **Purpose**: Pin lock configuration editor.
* **Button Specification**:
  * *Re-authenticate Biometrics*: Triggers iOS FaceID loop.

### 9.8 Screen: Settings
* **Purpose**: Master configuration manager.
* **Layout Structure**:
  * Grouped settings categories matching standard iOS style.

### 9.9 Screen: Backup
* **Purpose**: Managing manual ZIP backup exports.
* **Button Specification**:
  * *Generate AES-GCM Backup*: Encrypts database, launches system share sheet.

### 9.10 Screen: Cloud Sync
* **Purpose**: Sync logs checks.
* **Layout Structure**:
  * Log events showing CloudKit sync transaction logs.

### 9.11 Screen: Support
* **Purpose**: Submitting support requests.
* **Form Fields**:
  * *Issue Description*: Keyboard: `default`, Placeholder: "Explain the bug...", Required.

### 9.12 Screen: About
* **Purpose**: App version and legal licenses listings.
* **Layout Structure**:
  * Pinned layout centered branding details, followed by legal text lines.

---

## 10. Matrices & Inventories

### 10.1 Screen Inventory

Below is the official list of screens cataloged by their stage level and navigation type:

| ID | Screen Name | Stage | Primary Nav Type | Required Data Keys | Exit Destinations |
|:---|:---|:---|:---|:---|:---|
| SCR-01 | Splash | All | Full Screen | System configs | Diagnostic / Dashboard |
| SCR-02 | Onboarding Diagnostic | All | Full Screen Wizard | Survey questions | Dashboard |
| SCR-03 | Login | All | Form Stack | User inputs | Dashboard / Signup |
| SCR-04 | Signup | All | Form Stack | User inputs | Profile Setup |
| SCR-05 | Forgot Password | All | Form Stack | User inputs | Login |
| SCR-06 | Profile Setup | All | Form Stack | User inputs | Notifications Setup |
| SCR-07 | Notifications Setup | All | Action Screen | Device permissions | Dashboard |
| SCR-08 | Dynamic Dashboard | All | Tab View | TIS, Habits, OKRs | Sandbox / Planner |
| SCR-09 | Today's Mission | All | List Page | Daily objectives | Dashboard |
| SCR-10 | Daily Planner | All | Timeline | Calendar events | Focus Session |
| SCR-11 | Habits View | All | Grid | Habit configs | Habit Details |
| SCR-12 | Habit Details | All | Charts Page | Streak logs | Habits View |
| SCR-13 | Goals Map | All | Column Board | OKR structures | Goal Details |
| SCR-14 | Goal Details | All | Metric Details | Progress indicators | Goals Map |
| SCR-15 | Vision Board | All | Grid Matrix | Media links | Dashboard |
| SCR-16 | Calendar | All | Monthly Calendar | EventKit registers | Meetings Planner |
| SCR-17 | Meetings Planner | All | Form Sheet | Meeting variables | Calendar |
| SCR-18 | AI Mentor | All | Grid Card View | Mentor configs | Chat Thread |
| SCR-19 | AI Chat | All | Stream Page | Message registers | Mentor |
| SCR-20 | Voice Notes | All | Waveform Log | Audio hashes | Chat Thread |
| SCR-21 | Coding Dashboard | Stage 2 | Dynamic Overview | DSA problem states | Roadmaps / Editor |
| SCR-22 | Learning Roadmap | Stage 2 | Tree Grid | Java nodes | Topic Details |
| SCR-23 | Java Learning | Stage 2 | Reader Panel | Textbook pages | Recall Flashcards |
| SCR-24 | DSA Learning | Stage 2 | List Directory | Array problem indices | Topic Details |
| SCR-25 | Topic Details | Stage 2 | Theory Sheet | Syllabus | Sandbox Editor |
| SCR-26 | Practice Problems Sandbox | Stage 2 | Code Compiler | Code text file, unit tests | DSA Learning |
| SCR-27 | Quiz | Stage 2 | Quiz Cards | Test vectors | Dashboard |
| SCR-28 | Coding Progress | Stage 2 | Line Graphs | Submissions log | Dashboard |
| SCR-29 | Typing Practice | Stage 2 | Game Arena | Input keys | Dashboard |
| SCR-30 | Communication Practice | Stage 3 | Form Text | Dialogue scenarios | Dashboard |
| SCR-31 | Interview Practice | Stage 3 | Chat Dialogue | Question templates | Dashboard |
| SCR-32 | Health Dashboard | Stage 1 | Overview Grid | Workouts, sleep debt | Workout Planner |
| SCR-33 | Sleep | Stage 1 | Bar Graphs | HealthKit logs | Health Dashboard |
| SCR-34 | Workout Dashboard | Stage 1 | Routine List | Routines list | Workout Session |
| SCR-35 | Workout Session | Stage 1 | Live Tracker | Exercise tables, set logs | Workout Dashboard |
| SCR-36 | Exercise Detail | Stage 1 | Line Graphs | Set logs history | Workout Session |
| SCR-37 | Nutrition | Stage 1 | Input Form | Daily calorie limits | Health Dashboard |
| SCR-38 | Water | Stage 1 | Metric Dials | Intake levels | Health Dashboard |
| SCR-39 | Books | Stage 1 | Cover Matrix | Reading tracks | Book Details |
| SCR-40 | Book Details | Stage 1 | Details Sheet | Active chapters | Recall Quiz |
| SCR-41 | Reading Progress | Stage 1 | Flashcard Deck | Card logs | Books |
| SCR-42 | Finance Dashboard | Stage 3 | Overview Board | Net Worth, balances | Expense Entry |
| SCR-43 | Expense Entry | Stage 3 | Form Ledger | Cash variables | Finance Dashboard |
| SCR-44 | Savings | Stage 3 | Metric Dials | Savings limits | Finance Dashboard |
| SCR-45 | Salary | Stage 3 | Form Entry | Incomes | Finance Dashboard |
| SCR-46 | Investments | Stage 3 | Pie Graphs | Portfolio balances | Finance Dashboard |
| SCR-47 | Net Worth | Stage 3 | Line Graphs | Combined balance history | Finance Dashboard |
| SCR-48 | Business Dashboard | Stage 4 | Overview Board | Runway, Client states | Startup Planner |
| SCR-49 | Startup Planner | Stage 4 | 9-Box Grid | Lean Canvas variables | Business Dashboard |
| SCR-50 | Company Planner | Stage 4 | Table Simulator | Shareholder values | Business Dashboard |
| SCR-51 | Clients | Stage 4 | Contact Lists | Client indexes | Business Dashboard |
| SCR-52 | Projects | Stage 4 | Kanban Board | Task status | Business Dashboard |
| SCR-53 | CEO Dashboard | Stage 4 | Metric Overview | OKR, runway | Weekly Review |
| SCR-54 | Weekly Review | Stage 4 | Charts Page | Correlation logs | CEO Dashboard |
| SCR-55 | Analytics Dashboard | Stage 4 | Scatterplots | Correlation metrics | Settings |
| SCR-56 | Achievements | All | Grid | Unlocked assets | Settings |
| SCR-57 | XP | All | Grid | Character levels | Settings |
| SCR-58 | Leaderboard | All | Rankings Table | League indexes | Settings |
| SCR-59 | Documents | All | File Explorer | Vault hashes | Secure Vault |
| SCR-60 | Secure Vault | All | Security Sheet | Key registers | Settings |
| SCR-61 | Settings | All | Grouped List | Configurations | Backup / Cloud Sync |
| SCR-62 | Backup | All | Actions Sheet | SQLite files | Settings |
| SCR-63 | Cloud Sync | All | Sync Logs | Transaction queues | Settings |
| SCR-64 | Support | All | Form Stack | Issue logs | Settings |
| SCR-65 | About | All | Action Page | App version specs | Settings |

---

### 10.2 Navigation Map

The structural pathways map navigation flows directly based on dynamic stage rules:

```
[ ENTRY: Splash ] ──► [ BIOMETRICS: Authentication ] ──► [ TabView: Dynamic Root ]
                                                              │
    ┌─────────────────────── TabView Selection ───────────────┼────────────────────────┐
    ▼                                                         ▼                        ▼
[ Dynamic Dashboard ]                                 [ AI Board Chat ]       [ Settings Page ]
  ├── (Stage 1: Employee)                               ├── CTO Thread           ├── Backup Settings
  │     ├── Habits List ──► Details                     ├── CFO Thread           ├── Cloud Sync Logs
  │     └── Sleep Stats ──► Details                     ├── CMO Thread           └── Support Form
  ├── (Stage 2: Developer)                              └── Coach Thread
  │     ├── Learning Roadmaps ──► Topic Details
  │     └── Practice Sandbox ──► Code Compiler
  ├── (Stage 3: Entrepreneur)
  │     ├── Lean Canvas ──► Business Details
  │     └── Speech Analyzer ──► Rhetoric Results
  └── (Stage 4: CEO)
        ├── OKR objectives ──► Detail Progress
        └── Cap Table Simulator ──► Dilution Grid
```

---

### 10.3 Interaction Matrix

The table below catalogs system outcomes mapped to gestures performed on UI components:

| Source Screen | UI Element | Gesture | Event Trigger | System Outcome | Haptic Feedback Profile |
|:---|:---|:---|:---|:---|:---|
| Dashboard | Habit Item | Swipe Right | Habit Checked | Streaks incremented, XP added. | Sharp single tap ($0.05\text{s}$) |
| Dashboard | Task Block | Swipe Left | Block Deleted | Soft-delete flag set. | Medium warning pulse |
| Code Sandbox | Text Editor | Double Tap | Focus Editor | Virtual monospaced keyboard launches. | None |
| Dynamic Tree | Locked Node | Tap Node | Locked Select | Pop-up notification showing locked reason. | Double error buzz |
| Speech Recorder| Mic Button | Tap | Start Record | Microphone active, starts recording. | Soft start feedback |
| Finance Ledger | Expense item | Long Press | Transaction Action | Modal sheet launches with Delete/Edit choices. | Medium click |
| Flashcards | Flashcard Card | Tap | Flip Card | Card pivots $180\text{d}$ to show explanation. | Soft click |
| Settings | Sync Status | Pull Down | Sync Query | Runs CloudKit differential check. | Pulse loop feedback |

---

### 10.4 Component Usage Matrix

Exhaustive index mapping design system elements to operational app screens:

| ID | Screen Name | Cards | Charts | Forms | Lists | Dialogs | Bottom Sheets |
|:---|:---|:---|:---|:---|:---|:---|:---|
| SCR-01 | Splash | None | None | None | None | None | None |
| SCR-02 | Onboarding Diagnostic | Yes | None | Yes | None | Yes | None |
| SCR-03 | Login | None | None | Yes | None | Yes | None |
| SCR-04 | Signup | None | None | Yes | None | Yes | None |
| SCR-08 | Dynamic Dashboard | Yes | None | None | Yes | Yes | Yes |
| SCR-12 | Habit Details | Yes | Yes | Yes | None | None | Yes |
| SCR-17 | Meetings Planner | Yes | None | Yes | None | None | Yes |
| SCR-19 | AI Chat | Yes | None | Yes | Yes | None | None |
| SCR-26 | Practice Problems Sandbox | Yes | None | Yes | None | Yes | Yes |
| SCR-35 | Workout Session | Yes | None | Yes | Yes | Yes | Yes |
| SCR-43 | Expense Entry | Yes | None | Yes | None | None | Yes |
| SCR-46 | Investments | Yes | Yes | Yes | Yes | None | Yes |
| SCR-49 | Startup Planner | Yes | None | Yes | Yes | Yes | Yes |
| SCR-53 | CEO Dashboard | Yes | Yes | None | Yes | Yes | Yes |
| SCR-59 | Documents | Yes | None | None | Yes | Yes | Yes |
| SCR-61 | Settings | None | None | None | Yes | Yes | Yes |
