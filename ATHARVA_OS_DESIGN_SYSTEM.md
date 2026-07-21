# UI/UX DESIGN SYSTEM SPECIFICATION
## PRODUCT: ATHARVA OS (iOS Native Application)
### Version: 1.0.0
### Date: July 21, 2026

---

## 1. Brand Identity

### 1.1 App Personality
ATHARVA OS maintains a focused, disciplined, and executive brand character. It is styled as a personal advisory terminal that guides a user's transformation from Employee to CEO.
* **App Tone**: Assertive, analytical, silent, structured, and premium.
* **Brand Values**:
  * **Mastery**: Focuses on structured execution (roadmaps, compilers, speech reviews) rather than gamification gimmicks.
  * **Precision**: Eliminates unnecessary visual accents. Information density is prioritized, using clean layouts and clear grids.
  * **Privacy**: Emphasizes on-device security through muted, industrial themes and secure design patterns.
* **Design Philosophy**:
  * Adheres to **Apple Human Interface Guidelines (HIG)**.
  * Uses **Glassmorphism** (translucent materials, fine borders, dynamic background blurs) to represent layers of context, indicating the user's focus states.

---

## 2. Color System

The color system uses custom HSL palettes optimized for contrast and accessibility under both dark and light iOS color modes.

### 2.1 Dark Mode Palette (Primary)
* **Primary (Brand)**: `Hex #0A84FF` | `HSL(211, 100%, 52%)` -- High-vibrancy Apple Blue
* **Secondary**: `Hex #8E8E93` | `HSL(240, 2%, 57%)` -- Muted Industrial Gray
* **Accent**: `Hex #BF5AF2` | `HSL(278, 87%, 65%)` -- Executive Purple (denotes TIS growth milestones)
* **Success**: `Hex #30D158` | `HSL(135, 62%, 50%)` -- Compliance Green
* **Warning**: `Hex #FFD60A` | `HSL(50, 100%, 52%)` -- Burnout Alert Yellow
* **Error**: `Hex #FF453A` | `HSL(3, 100%, 62%)` -- Penalty Red
* **Info**: `Hex #64D2FF` | `HSL(197, 100%, 69%)` -- Cyan
* **Background (System)**: `Hex #000000` | `HSL(0, 0%, 0%)` -- Deep Pure Black (OLED optimized)
* **Surface (Vibrant Thin)**: `Hex #1C1C1E` with $0.70\text{ opacity}$ | `HSL(240, 2%, 11%)`
* **Card Material**: `Hex #2C2C2E` with $0.60\text{ opacity}$ | `HSL(240, 2%, 18%)`
* **Border Line**: `Hex #38383A` with $0.40\text{ opacity}$ | `HSL(240, 2%, 23%)`
* **Text Primary**: `Hex #FFFFFF` | `HSL(0, 0%, 100%)`
* **Text Secondary**: `Hex #EBEBF5` with $0.60\text{ opacity}$ | `HSL(240, 2%, 95%)`
* **Text Tertiary**: `Hex #EBEBF5` with $0.30\text{ opacity}$ | `HSL(240, 2%, 95%)`

### 2.2 Light Mode Palette (Adaptive Fallback)
* **Primary (Brand)**: `Hex #007AFF` | `HSL(211, 100%, 50%)`
* **Secondary**: `Hex #8F8F93` | `HSL(240, 2%, 57%)`
* **Accent**: `Hex #AF52DE` | `HSL(278, 69%, 59%)`
* **Success**: `Hex #34C759` | `HSL(135, 59%, 49%)`
* **Warning**: `Hex #FFCC00` | `HSL(48, 100%, 50%)`
* **Error**: `Hex #FF3B30` | `HSL(3, 100%, 60%)`
* **Background (System)**: `Hex #F2F2F7` | `HSL(240, 5%, 96%)`
* **Surface (Vibrant Thin)**: `Hex #FFFFFF` with $0.80\text{ opacity}$ | `HSL(0, 0%, 100%)`
* **Card Material**: `Hex #FFFFFF` with $0.90\text{ opacity}$ | `HSL(0, 0%, 100%)`
* **Border Line**: `Hex #C7C7CC` | `HSL(240, 2%, 80%)`
* **Text Primary**: `Hex #000000` | `HSL(0, 0%, 0%)`
* **Text Secondary**: `Hex #3C3C43` with $0.60\text{ opacity}$ | `HSL(240, 2%, 26%)`

---

## 3. Typography

The typography structure relies on the **San Francisco (SF)** family, utilizing specific tracking (letter-spacing) values defined by Apple for iOS.

### 3.1 Text Hierarchy Table
| Token Name | Font Family | Size | Weight | Tracking | Line Height | Usage |
|:---|:---|:---|:---|:---|:---|:---|
| `font_large_title` | SF Pro Display | 34pt | Bold | 0.38pt | 41pt | Screen headers |
| `font_title_1` | SF Pro Display | 28pt | Semibold | 0.36pt | 34pt | Section title |
| `font_title_2` | SF Pro Display | 22pt | Semibold | 0.35pt | 28pt | Modal title |
| `font_title_3` | SF Pro Display | 20pt | Medium | 0.38pt | 25pt | Card title |
| `font_headline` | SF Pro Text | 17pt | Semibold | -0.41pt | 22pt | Card headers |
| `font_body` | SF Pro Text | 17pt | Regular | -0.41pt | 22pt | Journals, details |
| `font_subheadline` | SF Pro Text | 15pt | Regular | -0.24pt | 20pt | Detail subtitles |
| `font_footnote` | SF Pro Text | 13pt | Regular | -0.08pt | 18pt | Time logs |
| `font_caption_1` | SF Pro Text | 12pt | Medium | 0.00pt | 16pt | Stat badges |
| `font_caption_2` | SF Pro Text | 11pt | Regular | 0.06pt | 13pt | Minor labels |
| `font_code` | SF Mono | 14pt | Regular | -0.05pt | 19pt | Coding Sandbox |

---

## 4. Spacing System

Layout grids are based on a **4pt/8pt grid system** to align with iOS layout conventions.

### 4.1 Spacing Tokens
* `spacing_xxs`: $4\text{pt}$ (Padding between avatar and text tags)
* `spacing_xs`: $8\text{pt}$ (Padding inside small badges)
* `spacing_s`: $12\text{pt}$ (Spacing between items inside a vertical card list)
* `spacing_m`: $16\text{pt}$ (Standard padding for cards, page gutters)
* `spacing_l`: $24\text{pt}$ (Spacing between distinct dashboard sections)
* `spacing_xl`: $32\text{pt}$ (Padding below large title headers)

### 4.2 Material Elevation & Shadows
* **Tier 1 (Surface Background)**: $0\text{pt}$ elevation. No shadow.
* **Tier 2 (Cards & Modules)**: Background blur material with a $1\text{pt}$ border stroke (`Hex #38383A` at $0.40\text{ opacity}$).
  * **Shadow**: Color: `Hex #000000`, Opacity: $0.15$, Radius: $8\text{pt}$, Y-Offset: $4\text{pt}$.
* **Tier 3 (Floating Actions & Modals)**: Expanded material layer.
  * **Shadow**: Color: `Hex #000000`, Opacity: $0.25$, Radius: $16\text{pt}$, Y-Offset: $8\text{pt}$.
* **Corner Radius Standard**:
  * Cards: $16\text{pt}$ (Continuous corner curve matching Apple Squircle styling).
  * Buttons & Text Fields: $12\text{pt}$.
  * Badges & Tags: $8\text{pt}$.

---

## 5. Icon System

* **Icon Library**: Pinned strictly to **SF Symbols 5+**.
* **Visual Style**: Icons must use the `monochrome` rendering mode by default. For alerts, status markers, or rewards, use the `multicolor` or `hierarchical` mode configured with the primary success/warning/accent color tokens.
* **Size Configurations**:
  * Pinned Bottom Navigation Tab: $24\text{pt}$ size, `medium` scale weight.
  * List Row Icons: $18\text{pt}$ size, `regular` scale weight.
  * Card Header Actions: $16\text{pt}$ size, `semibold` scale weight.

---

## 6. Buttons

Buttons maintain a clean visual layout, relying on standard padding heights to align with the 8pt grid.

* **Primary Button**:
  * **Style**: Filled background (`Primary Blue` token), Text: `White` (bold), Corner Radius: $12\text{pt}$.
  * **Metrics**: Height: $50\text{pt}$, horizontal padding: $24\text{pt}$.
* **Secondary Button**:
  * **Style**: Filled background (`Surface Gray` at $0.70\text{ opacity}$), Text: `Primary Blue` (semibold).
  * **Metrics**: Height: $44\text{pt}$.
* **Outline Button**:
  * **Style**: Transparent background, Border: $1\text{pt}$ solid (`Border Line` token), Text: `White` (regular).
  * **Metrics**: Height: $44\text{pt}$.
* **Ghost Button**:
  * **Style**: Transparent background, Text: `Secondary Gray` (regular).
  * **Metrics**: Height: $36\text{pt}$.
* **Floating Action Button (FAB)**:
  * **Style**: Circular ($56\text{pt} \times 56\text{pt}$), Background: `Accent Purple` or `Primary Blue`, Icon: `White` ($22\text{pt}$ size). Elevated Tier 3 shadow.
* **Loading State**:
  * Tapping displays a centered Apple system spinner (`ActivityIndicator` style, $20\text{pt}$ size). Button text opacity transitions to $0.0$.
* **Disabled State**:
  * Background: `Card Material` at $0.30\text{ opacity}$, Text: `Text Secondary` at $0.30\text{ opacity}$. Disables all tap gestures.

---

## 7. Inputs

* **Text Fields**:
  * **Style**: Background: `Surface Gray` at $0.60\text{ opacity}$, Border: $1\text{pt}$ border on focus, Text: `Text Primary`, Height: $48\text{pt}$.
* **Search Input**:
  * Pinned SF Symbol `magnifyingglass` on the left edge. Dismiss button 'x' on the right.
* **OTP Input**:
  * 6 individual square text boxes ($48\text{pt} \times 48\text{pt}$ each), separated by $8\text{pt}$ spacing. Focus highlights active box border in `Primary Blue`.
* **Chips & Filter Tags**:
  * Height: $32\text{pt}$, background: `Surface Gray` when inactive, `Primary Blue` when active. Rounded corner: $16\text{pt}$ (capsule shape).

---

## 8. Cards

Cards use translucent materials to separate layout components visually.

```
┌──────────────────────────────────────────────┐
│  [SF Icon] Card Header Title       [SF Action]│ -- Tier 2 Blur Material
├──────────────────────────────────────────────┤
│  Card Body Content                           │
│  - Text body / Progress rings / Graphs       │
├──────────────────────────────────────────────┤
│  [Optional Card Footer Meta Tags]           │
└──────────────────────────────────────────────┘
```

* **Dashboard Card**: Width: Screen width minus $32\text{pt}$ ($16\text{pt}$ margins). Corner Radius: $16\text{pt}$, background: `Card Material` ($0.60\text{ opacity}$).
* **Statistics Card**: Height: $110\text{pt}$ (fits 2 columns in a dashboard layout grid). Displays bold numbers ($32\text{pt}$ font size) with text captions.
* **AI Chat Card**: Minimal card containing a $1\text{pt}$ border in `Accent Purple` to demarcate advisor interactions.
* **Workout Progressive Overload Card**: Includes sets table, weight log inputs, and target indicators highlighted in light green when RPE goals are met.

---

## 9. Navigation Components

* **Bottom Tab Bar**:
  * Background: `Surface Gray` ($0.85\text{ opacity}$ with background blur), Height: $83\text{pt}$ (includes safe area layout offset for iPhone Pro Max models).
* **Top Navigation Header**:
  * Height: $44\text{pt}$ (plus device status bar). Large title scrolls to standard inline title with smooth vertical offsets.
* **Context Tabs**:
  * Segmented controls with sliding background pill matching HIG patterns.

---

## 10. Lists

* **Checked Habit List Item**:
  * Height: $64\text{pt}$, Background: `Card Material`. Left-aligned checkbox trigger icon. Checked state slides the checkbox icon transition to `Success Green` and reduces title text opacity to $0.40$.
* **Roadmap Curriculum Item**:
  * Includes a left-aligned vertical tree connecting line, a central module title, and a right-aligned unlock indicator symbol.

---

## 11. Tables

* **Ledger Table**:
  * Horizontal margins: $16\text{pt}$, header text: `font_footnote` in `Secondary Gray`.
  * Rows: Height: $48\text{pt}$, divided by a $0.5\text{pt}$ separator line (`Border Line` token). Numeric financial inputs are aligned right.

---

## 12. Charts

* **Progress Line Charts**:
  * Rendered with thin Bezier curves ($2\text{pt}$ stroke weight) in `Primary Blue` or `Accent Purple`.
  * Background gradient fill below the path line, transitioning from primary color ($0.15\text{ opacity}$) to transparent at the chart bottom.
* **Correlation Scatterplot**:
  * Plots daily coordinates. Point indicators use circular shapes ($6\text{pt}$ diameter). Trend line plotted in `Accent Purple`.

---

## 13. Progress Components

* **Radial Progress Rings**:
  * Stroke weight: $10\text{pt}$, track color: `Border Line` token, active progress indicator colored in `Primary Blue` or `Success Green`. Includes a central text indicator showing percentage values (e.g., "75%").
* **Linear Progress Bars**:
  * Track Height: $6\text{pt}$, background: `Border Line`, active indicator rounded capsule in `Success Green`.

---

## 14. XP Components

* **XP Stat Progress Badge**:
  * Capsule layout containing an attribute abbreviation (e.g., "INT" or "STR" in semibold `font_caption_1`), paired with an XP points indicator (e.g., "+150 XP").
* **Level Upgrade Visual**:
  * Centered level ring showing: "LEVEL UP" with character level change animations ($4\text{pt}$ scale pop).

---

## 15. Achievement Components

* **Unlocked Badge Card**:
  * Hexagonal frame containing a centered SF symbol matching the achievement category, styled in `Accent Purple` with gold gradient details.
* **Locked Badge Card**:
  * Muted version of the hexagonal card template, styled in `Border Line` with a padlock symbol at the center.

---

## 16. Empty States

* **Layout Standard**:
  * Pinned centered layout containing:
    * Standard vector icon in `Secondary Gray` ($64\text{pt}$ height).
    * Header title text (`font_headline` weight, `Text Primary`).
    * Description label (`font_subheadline`, `Text Secondary` at $0.60\text{ opacity}$).
    * Margin space ($16\text{pt}$) followed by a Primary CTA button.

---

## 17. Loading States

* **Skeletal Pulse Grid**:
  * Shimmer blocks simulate list items or cards. Shimmer animation uses a linear gradient moving left-to-right:
    * `Card Material` $\to$ `Border Line` $\to$ `Card Material` ($1.5\text{s}$ duration, linear loop).

---

## 18. Error States

* **Inline Action Banner**:
  * Height: $56\text{pt}$, Background: `Error Red` at $0.15\text{ opacity}$, Border: $1\text{pt}$ solid `Error Red` ($0.40\text{ opacity}$), Text: `White` (medium). Includes a right-aligned "Retry" ghost button.

---

## 19. Success States

* **Confirmation Modal**:
  * Full-screen blur overlay containing a large green checkmark ($80\text{pt}$ diameter) which completes a circle-draw animation at $0.4\text{s}$, followed by a device haptic pulse trigger.

---

## 20. Dialogs

* **OS Action Sheet**:
  * Native sheet slide-up matching HIG guidelines. Top title text, followed by choice buttons. Destructive actions highlighted in red text.

---

## 21. Bottom Sheets

* **Sheet Detents**:
  * Bottom sheets configure standard detents: `.medium()` ($50\%$ view height) and `.large()` ($95\%$ view height).
  * Includes a rounded drag handle ($36\text{pt}$ width, $5\text{pt}$ height, colored `Border Line` at $0.50\text{ opacity}$) centered at the top header edge.

---

## 22. Toasts

* **Toast Alert Layout**:
  * Rounded bar ($44\text{pt}$ height) floating at the top of the active view. Background: `Surface Gray` with $0.90\text{ opacity}$, featuring a drop shadow. Auto-dismisses after $1.5\text{ seconds}$.

---

## 23. Snackbars

* **Interactive Snackbar**:
  * Floats above the bottom tab bar navigation layer. Includes a left-aligned text label and a right-aligned action button in `Success Green`.

---

## 24. Widgets

* **Small Widget Matrix ($2 \times 2$ Grid)**:
  * Dimensions: $169\text{pt} \times 169\text{pt}$ (Standard iOS). Outer padding margin: $16\text{pt}$.
* **Medium Widget Matrix ($4 \times 2$ Grid)**:
  * Dimensions: $360\text{pt} \times 169\text{pt}$. Matches standard system margins.

---

## 25. Dashboard Components

* **Dynamic Sensor Header**:
  * Displays small inline indicators showing local weather and active time-of-day stats, adapting active dashboard features automatically.

---

## 26. Calendar Components

* **Time-Block Layout Grid**:
  * Displays hour increments along the left edge. Scheduled blocks appear as colored cards positioned on the calendar grid, with width matching block durations.

---

## 27. AI Chat Components

* **User Chat Bubble**:
  * Aligned right, background: `Primary Blue` ($0.85\text{ opacity}$), Text: `White`, Corner Radius: $16\text{pt}$ (bottom-right corner is styled square to indicate bubble tip direction).
* **Advisor Chat Bubble**:
  * Aligned left, background: `Card Material`, Border: $1\text{pt}$ `Border Line` with a custom `Accent Purple` top accent.

---

## 28. Habit Components

* **Weekly Compliance Dot Matrix**:
  * Displays a row of 7 circular dots (representing days of the week). Unchecked days display as grey outlines; completed days animate to filled green circles.

---

## 29. Finance Components

* **Net Worth Dial Card**:
  * Large, high-contrast metric display showing net worth numbers ($36\text{pt}$ semibold font), with a small line chart showing the monthly balance trend.

---

## 30. Coding Components

* **Monospace Sandbox Editor**:
  * Code view uses a dark syntax theme:
    * Background: `Black` ($0.95\text{ opacity}$).
    * Text: Keywords in `Accent Purple`, variables in `White`, comments in `Secondary Gray`.

---

## 31. Business Components

* **Lean Canvas Grid Segment**:
  * Outlines the 9 sectors of the Lean Canvas. Tapping a cell expands the container into a full-screen editor modal.

---

## 32. Gym Components

* **Overload Progression Row**:
  * Display set inputs structured as: `[Set #]  [Weight input field]  [Reps input field]  [RPE picker]`.

---

## 33. Reading Components

* **Active Recall Quiz Card**:
  * Prompts the user with text fields, validating chapter retention metrics.

---

## 34. Analytics Components

* **Pearson Correlation Badge**:
  * Displays correlation values between personal physical data and cognitive outputs (e.g., "Sleep & typing speed correlation: 0.76 - High").

---

## 35. Motion System

Animations use SwiftUI's native spring models to replicate realistic physics and ensure UI responsiveness.

```
[ GESTURE / TAP ] ──► [ SwiftUI Spring Engine ] ──► [ SCREEN TRANSITION ]
                        - Card Expand: spring(0.38, 0.72)
                        - Page Nav: spring(0.55, 0.82)
```

### 35.1 Animation Curve Metrics
* **Card Expand/Transition Animation**:
  * Curve: `spring(response: 0.38, dampingFraction: 0.72, blendDuration: 0)`
  * Focuses on quick entry with minimal spring oscillations.
* **Screen Slide Navigation**:
  * Curve: `spring(response: 0.55, dampingFraction: 0.82, blendDuration: 0)`
* **Reward / Level Up Pop-up**:
  * Curve: `spring(response: 0.42, dampingFraction: 0.65, blendDuration: 0)`
* **Active Shimmer Loading Pulse**:
  * Duration: $1.5\text{s}$, transition curve: `linear`, infinite repeat logic.

---

## 36. Accessibility

* **AA Color Contrast Compliance**:
  * All text color combinations are verified to meet WCAG 2.1 AA rules, maintaining contrast ratios of at least 4.5:1.
* **Touch Target Layout**:
  * Pinned buttons and checklists maintain a minimum target grid size of $44\text{pt} \times 44\text{pt}$.
* **VoiceOver Focus Priority**:
  * Screen views arrange accessibility descriptors sequentially, reading titles, descriptions, and interactive button groups in a logical top-to-bottom order.

---

## 37. Responsive Behavior

### 37.1 Screen Dimensions Matrix
* **iPhone SE (Small Screen)**:
  * Gutters drop from $16\text{pt}$ to $12\text{pt}$ margins. Font sizes for large titles are capped at $28\text{pt}$ to prevent layout wrap collisions.
* **iPhone Pro Max (Large Screen)**:
  * Standard margins expand from $16\text{pt}$ to $20\text{pt}$. Double column card layouts display on the primary dashboard view.
* **Landscape Mode Configurations**:
  * Tab bar navigation slides from the bottom edge to the left edge of the screen, displaying as a vertical sidebar.

---

## 38. Design Tokens

Below is a JSON-equivalent database detailing the design token configurations for developers:

```json
{
  "colors": {
    "primary": "#0A84FF",
    "secondary": "#8E8E93",
    "accent": "#BF5AF2",
    "success": "#30D158",
    "warning": "#FFD60A",
    "error": "#FF453A",
    "bg_dark": "#000000",
    "surface_dark": "rgba(28, 28, 30, 0.70)",
    "border_dark": "rgba(56, 56, 58, 0.40)"
  },
  "spacing": {
    "xxs": 4,
    "xs": 8,
    "s": 12,
    "m": 16,
    "l": 24,
    "xl": 32
  },
  "corner_radius": {
    "small": 8,
    "regular": 12,
    "card": 16
  },
  "springs": {
    "expand": {
      "response": 0.38,
      "damping": 0.72
    },
    "navigate": {
      "response": 0.55,
      "damping": 0.82
    }
  }
}
```

---

## 39. Reusable Component Library

The development model maps design system tokens to reusable component classes:
* `VibrantCardContainer`: Translucent box wrapper configuring corner radius, background materials, and border outlines.
* `PrimaryActionButton`: Standardized primary blue filled button incorporating system spinner triggers.
* `MetricDialView`: Large metric text element paired with a subtitle caption and optional trend line.
* `ComplianceMatrix`: Row of circular day indicators displaying active compliance logs.

---

## 40. Naming Conventions

* **Nomenclature Rules**:
  * Design tokens and assets are named using clean, dot-separated category strings:
    * `color.brand.primary`
    * `spacing.layout.margin`
    * `font.display.largeTitle`
    * `animation.spring.navigate`
  * Layout variables mapped inside code repositories must match these token name keys exactly.
