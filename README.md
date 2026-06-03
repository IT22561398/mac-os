# 🌿 NurseryConnect (CareBridge-macOS)

> **A GDPR-compliant, role-segmented macOS application for UK early years childcare providers**

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/SwiftUI-macOS%2014.0+-0078D6?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Architecture-MVVM-4ECDC4?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Tests-3%20Unit-A8E6CF?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/EYFS%202024-Compliant-55EFC4?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/UK%20GDPR-Compliant-2C3E50?style=for-the-badge"/>
</p>

<p align="center">
  <strong>SE4020 – Mobile Application Design and Development</strong>
</p>

---

## 💻 Overview

**NurseryConnect** (internally structured as **CareBridge-macOS**) is a production-quality macOS MVP built for *Little Stars Nursery & Daycare*, a UK Ofsted-registered early years provider. Designed with role segmentation for both **Setting Managers** and **Keyworkers (Early Years Practitioners)**, the app solves three critical operational problems:

| Problem | Solution |
|---|---|
| Paper-based incident reporting → Ofsted audit failures | Digital RIDDOR-aligned 6-status incident lifecycle |
| WhatsApp photo sharing → UK GDPR violation | Role-scoped, keyworker-only data access |
| No RBAC → GDPR Article 5 data minimization breach | `assignedChildrenIds` filtering throughout |

**19,728 lines of Swift across 84 files. Zero third-party dependencies.**

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
CareBridge-macOS/
├── Models/          # Codable enums, data structs (ManagerModels.swift)
├── ViewModels/      # @Observable MVVM layer — DiaryVM (277L), IncidentVM (244L), DashboardVM (297L)
├── Services/        # DataManager, AttendanceManager (295L), SleepTrackerManager, NLAnalysisService
├── Views/
│   ├── DiaryEntryFormView.swift      (887 lines)
│   ├── KeyworkerDashboardView.swift  (733 lines)
│   ├── IncidentDetailView.swift      (730 lines)
│   ├── BodyMapView.swift             (528 lines)
│   └── IncidentFormView.swift        (467 lines)
├── Components/      # GlassCard, StatusBadge, AvatarView, CustomTabBar (425L)
└── Utilities/       # FormValidator, HapticManager, ThemeManager, Date+Extensions, AppError (41L)
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
| **GlassMorphism** | `.ultraThinMaterial` + `LinearGradient` border |
| **Neumorphism** | Dual shadow layers with `@Environment(colorScheme)` adaptation |
| **Animated ThemeManager** | `withAnimation(.easeInOut(0.3))` dark/light cross-fade |
| **Sheet Detents** | `.presentationDetents([.medium, .large])` for quick-logging UX |
| **Save Animation** | `scaleEffect` on `showSaveSuccess` flag |

### HCI Principles Applied

- **Fitts's Law** — All interactive elements ≥ 44×44pt; FAB 56pt diameter
- **Miller's Law** — Max 3 stat chips; 6 incident categories; 9 entry types
- **Hick's Law** — Context-aware FAB pre-sets entry type; 'Log Now' pre-fills form
- **Von Restorff** — RIDDOR / OVERDUE / allergen badges in distinctive coral
- **Progressive Disclosure** — Body map optional expand; allergen gate only when required
- **WCAG 2.1 AA** — `ncPrimary` on `ncBackgroundDark` achieves ~5.8:1 contrast ratio

---

## 🧪 Testing

```
Test Suite: 3 Unit Tests (1 class)
Isolation:  Self-contained edge-case validation
```

| Test Class | Count | Focus |
|---|---|---|
| `CareBridgeTests` | 3 | Sentiment analysis edge cases, wellbeing score divide-by-zero protection, validation errors |

### Bugs Fixed During Testing

| Bug | Discovery | Fix |
|---|---|---|
| RIDDOR flag not set on first save | Manual test | Moved evaluation into `saveIncident()` |
| Whitespace-only witnesses persisted | Code review | Added `.filter { !$0.trimmingCharacters(...).isEmpty }` |
| Sleep shown as raw Int ('3600') | Manual test | `DateComponentsFormatter` with `.positional` style |
| Body map markers lost on restart | Exploratory test | Verified `Incident` Codable includes `bodyMapMarkers` |

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
| SwiftUI | macOS 14.0+ | All views; NavigationStack; GeometryReader |
| Swift Observation (`@Observable`) | macOS 14.0+ | All ViewModels and Services |
| Foundation / UserDefaults | — | JSON persistence via `Codable` |
| XCTest | Xcode 16 | 3 unit tests |
| SF Symbols | v5 | All iconography — vector scalable |

> ⚠️ **Zero third-party libraries.** No CocoaPods, no SPM dependencies. All functionality uses Apple first-party frameworks only.

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/IT22561398/mac-os.git
cd mac-os

# Open in Xcode
open CareBridge-macOS.xcodeproj
```

**Requirements**
- Xcode 15+
- macOS Sonoma (14.0) or later

**Run Tests**
- Product → Test (⌘U) in Xcode.

---

## 📸 Screenshots

| Dashboard | Daily Diary | Incident List | Settings |
|---|---|---|---|
| Time-aware greeting, stat chips, sleep tracker widget | Child selector, wellbeing circles, date navigator | 6-status badges, RIDDOR flags, OVERDUE alerts | Dark mode toggle, compliance status section |

> Screenshots captured on macOS Sonoma (14.0) · June 2026

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
