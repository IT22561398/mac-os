# 🌿 NurseryConnect

> **A GDPR-compliant, role-segmented iOS application for UK early years childcare providers**

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/SwiftUI-iOS%2017+-0078D6?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Architecture-MVVM-4ECDC4?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Tests-25%20Unit%20%7C%204%20UI-A8E6CF?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/EYFS%202024-Compliant-55EFC4?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/UK%20GDPR-Compliant-2C3E50?style=for-the-badge"/>
</p>

<p align="center">
  <strong>SE4020 – Mobile Application Design and Development</strong>
</p>

---

## 📱 Overview

**NurseryConnect** is a production-quality iOS MVP built for *Little Stars Nursery & Daycare*, a UK Ofsted-registered early years provider. Designed from the perspective of a **Keyworker (Early Years Practitioner)**, the app solves three critical operational problems:

| Problem | Solution |
|---|---|
| Paper-based incident reporting → Ofsted audit failures | Digital RIDDOR-aligned 6-status incident lifecycle |
| WhatsApp photo sharing → UK GDPR violation | Role-scoped, keyworker-only data access |
| No RBAC → GDPR Article 5 data minimization breach | `assignedChildrenIds` filtering throughout |

**14,318 lines of Swift across 57 files. Zero third-party dependencies.**

---

## ✨ Features

### 📓 Daily Diary & Activity Monitoring
- **9 Entry Types**: Arrival, Departure, Activity, Sleep, Nappy, Meal, Wellbeing Check, Milestone, Note
- **EYFS Wellbeing Checks**: 3-period mood recording (Arrival / Midday / Departure) with 5 mood states
- **Live Sleep Tracker**: Real-time timer with SIDS-aware position recording (back/side/front)
- **FSA Nutrition Monitoring**: 6-level portion scale (All / Most / Half / A Little / None / Refused)
- **Allergen Confirmation Gate**: Blocks meal save for allergic children until keyworker explicitly confirms
- **10 Activity Types**: Indoor Play, Outdoor Play, Reading, Arts & Crafts, Educational, and more

### 🚨 Incident Management
- **RIDDOR-Aligned Workflow**: 6-category classification (Minor Accident, First Aid, Safeguarding Concern, Near Miss, Allergic Reaction, Medical Incident)
- **6-Status Lifecycle**: `draft → submitted → underReview → countersigned → parentNotified → acknowledged`
- **Interactive Body Map**: 13 front zones + 11 back zones using GeometryReader normalised coordinates
- **Evidential Timestamp Lock**: Incident `dateTime` locked at creation — immutable audit trail
- **Dynamic Witness List**: Add/remove witnesses; whitespace-only entries auto-filtered

### 🏠 Smart Dashboard
- **Recommendation Engine**: 3-tier priority (High / Medium / Low) alerts per child
- **Recommendation Types**: `missingWellbeing`, `missingMeal`, `nappyDue`, `missingSleep`, `allergyAlert`
- **Live Sleep Tracker Widget**: Child avatar rows with start-sleep actions
- **'Log Now' Quick Actions**: Pre-fills diary form with recommended entry type (Hick's Law)

---

## 🏗️ Architecture

```
NurseryConnect/
├── Models/          # 16 Codable enums, all data structs (Models.swift 356L, Constants.swift 472L)
├── ViewModels/      # @Observable MVVM layer — DiaryVM, IncidentVM, DashboardVM (348L)
├── Services/        # DataManager, AttendanceManager (340L), SleepTrackerManager
├── Views/
│   ├── DiaryEntryFormView.swift      (922 lines)
│   ├── KeyworkerDashboardView.swift  (799 lines)
│   ├── IncidentDetailView.swift      (796 lines)
│   ├── BodyMapView.swift             (590 lines)
│   └── IncidentFormView.swift        (512 lines)
├── Components/      # GlassCard, StatusBadge, AvatarView, CustomTabBar (462L)
└── Utilities/       # FormValidator, HapticManager, ThemeManager, Date+Extensions
```

**Pattern**: MVVM + Observable Service Layer  
**State Management**: Swift 5.9 `@Observable` macro (compiler-enforced, replaces `@Published/@ObservableObject`)  
**Cross-VM Communication**: Custom `NotificationCenter` — `Notification.Name.entrySaved` decouples DiaryVM ↔ DashboardVM

---

## 🎨 Design System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| `ncPrimary` | `#4ECDC4` Soft Teal | Primary interactive elements |
| `ncSecondary` | `#FF6B6B` Warm Coral | Alerts, errors, high-priority |
| `ncAccent` | `#FFE66D` Golden Yellow | Positive indicators |
| `ncBackgroundDark` | `#1A1B2E` Dark Navy | Dark mode background |
| `ncSuccess` | `#A8E6CF` Mint Green | Acknowledged / completed |
| `ncWarning` | `#FFB347` Soft Orange | Pending / medium-priority |
| `ncMoodHappy` | `#55EFC4` Green Teal | Happy mood indicator |
| `ncMoodPoorly` | `#FF6B6B` Coral Red | Poorly — high attention |

### Advanced UI Techniques

| Technique | Implementation |
|---|---|
| **GlassMorphism** | `.ultraThinMaterial` + `LinearGradient` border (iOS 15+) |
| **Neumorphism** | Dual shadow layers with `@Environment(colorScheme)` adaptation |
| **Animated ThemeManager** | `withAnimation(.easeInOut(0.3))` dark/light cross-fade |
| **Sheet Detents** | `.presentationDetents([.medium, .large])` for quick-logging UX |
| **Save Animation** | `scaleEffect` on `showSaveSuccess` flag |

### HCI Principles Applied

- **Fitts's Law** — All interactive elements ≥ 44×44pt; FAB 56pt diameter
- **Miller's Law** — Max 3 stat chips; 6 incident categories; 6 entry types
- **Hick's Law** — Context-aware FAB pre-sets entry type; 'Log Now' pre-fills form
- **Von Restorff** — RIDDOR / OVERDUE / allergen badges in distinctive coral
- **Progressive Disclosure** — Body map optional expand; allergen gate only when required
- **WCAG 2.1 AA** — `ncPrimary` on `ncBackgroundDark` achieves ~5.8:1 contrast ratio

---

## 🧪 Testing

```
Test Suite: 25 Unit Tests (5 classes) + 4 UI Tests
Isolation:  TestDataIsolation.clearAppPersistence() in setUp() + tearDown()
UI Flags:   UITEST_MODE · UITEST_SKIP_SPLASH · UITEST_SKIP_ONBOARDING · UITEST_RESET_DATA
```

| Test Class | Count | Focus |
|---|---|---|
| `IncidentViewModelTests` | 5 | RIDDOR workflow, body map add/remove, timestamp locking |
| `FormValidatorTests` | 5 | Whitespace trimming, min-length, all error paths |
| `AttendanceManagerTests` | 7 | State machine, idempotency, persistence round-trip |
| `SleepTrackerManagerTests` | 4 | Duration formatting, HH:MM:SS timer, lifecycle |
| `MessageManagerTests` | 4 | Unread counts, mark-read, bucket filtering |

### Bugs Fixed During Testing

| Bug | Discovery | Fix |
|---|---|---|
| RIDDOR flag not set on first save | Unit test | Moved evaluation into `saveIncident()` |
| Whitespace-only witnesses persisted | Unit test | `.filter { !$0.trimmingCharacters(...).isEmpty }` |
| Sleep shown as raw Int ('3600') | Manual test | `DateComponentsFormatter` with `.positional` style |
| Body map markers lost on restart | Exploratory test | Verified `Incident` Codable includes `bodyMapMarkers` |
| SleepTracker tests non-deterministic | First run failure | Added `clearAppPersistence()` to `setUp()` |

---

## ⚖️ Regulatory Compliance

| Regulation | Status | Key Implementation |
|---|---|---|
| **UK GDPR** | ✅ Compliant | `assignedChildrenIds` data minimization; timestamp locking; on-device only |
| **EYFS 2024** | ✅ Compliant | Named keyworker, wellbeing checks, meal records, sleep/SIDS, same-day incident notification |
| **RIDDOR 2013** | ✅ Compliant | 6 incident categories, body map, witness recording, 6-status workflow |
| **Children Act 1989** | ✅ Compliant | Immutable safeguarding timestamps, need-to-know access control |
| **FSA Guidelines** | ✅ Compliant | 6-level portion scale, allergen confirmation gate, DrinkType classification |
| **Ofsted EIF 2023** | ✅ Compliant | Chronological incident log, RIDDOR badges, end-of-day checklist |

---

## 🛠️ Tech Stack

| Technology | Version | Usage |
|---|---|---|
| Swift | 6.0 / Xcode 16+ | Primary language; strict concurrency |
| SwiftUI | iOS 17+ | All views; NavigationStack; GeometryReader |
| Swift Observation (`@Observable`) | iOS 17+ | All ViewModels and Services |
| Foundation / UserDefaults | — | JSON persistence via `Codable` |
| UIKit (haptics only) | iOS 13+ | `UIImpactFeedbackGenerator` via `HapticManager` |
| XCTest / XCUITest | Xcode 16 | 25 unit + 4 UI tests |
| SF Symbols | v5 | All iconography — vector scalable |

> ⚠️ **Zero third-party libraries.** No CocoaPods, no SPM dependencies. All functionality uses Apple first-party frameworks only.

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/ArunaluB/carebridge-ios.git
cd carebridge-ios

# Open in Xcode
open Assignment1.xcodeproj
```

**Requirements**
- Xcode 16+
- iOS 17+ Simulator or device
- macOS Sonoma or later

**Run Tests**
```
Product → Test  (⌘U)
```
All 25 unit tests and 4 UI tests should pass with zero ordering dependencies due to `TestDataIsolation`.

---

## 📸 Screenshots

| Dashboard | Daily Diary | Incident List | Settings |
|---|---|---|---|
| Time-aware greeting, stat chips, sleep tracker widget | Child selector, wellbeing circles, date navigator | 6-status badges, RIDDOR flags, OVERDUE alerts | Dark mode toggle, compliance status section |

> Screenshots captured on iPhone 17 Pro Simulator (iOS 26.4) · April 7, 2026

---

## 📋 MVP Scope vs. Production

| Feature | MVP | Production |
|---|---|---|
| Data Storage | UserDefaults + Codable JSON | AWS S3 + PostgreSQL (eu-west-2), AES-256, TLS 1.3 |
| Authentication | Not implemented | AWS Cognito + TOTP MFA + Face ID |
| Push Notifications | In-app toast banner | APNs + FCM with delivery receipts |
| Data Retention | Permanent local | Auto-delete: diary 3yr, incidents until age 21 |
| RIDDOR Export | Not implemented | PDF generation for HSE submission |

---

## 📄 License

This project was developed for **SE4020 – Mobile Application Design and Development** at SLIIT.  
© 2026 Hesara P.K.A.N. (IT22561398). All rights reserved.
