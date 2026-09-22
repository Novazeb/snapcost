# SnapCost
> **Clean & Effortless Expense Scanner** — Modern on-device AI receipt scanner & financial expense tracker designed with European FinTech aesthetics (Revolut / Apple Wallet).

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)]()
[![Offline First](https://img.shields.io/badge/Architecture-Offline--First-orange.svg)]()

---

## Features

- **On-Device AI Receipt Scanner**: Real-time receipt scanning using `google_mlkit_text_recognition`. 100% offline & private.
- **Smart Regex OCR Engine**: Automatically extracts:
  - **Merchant / Store Name** (Filters noise, cleans capitalization)
  - **Transaction Date** (`DD/MM/YYYY`, `YYYY-MM-DD`, etc.)
  - **Total Amount** (`Rp`, `USD`, `TOTAL`, `GRAND TOTAL`)
  - **Auto-Categorization** (Maps store names to Food, Groceries, Transport, Bills, etc.)
- **European FinTech UI/UX**:
  - Ultra-clean minimalist layout inspired by Revolut & Apple Wallet.
  - Light Mode (`#F8F9FA` with emerald `#10B981`) & Dark Mode (`#0F172A` with neon mint `#34D399`).
  - Subtle 1px borders, smooth 16px rounded corners, and tactile haptic feedback.
- **Interactive Financial Dashboard**:
  - Hero monthly expenditure display with budget progress bar.
  - Category breakdown donut charts powered by `fl_chart`.
  - Grouped chronological transaction history (*Hari Ini*, *Kemarin*, specific date).
- **Biometric Security**:
  - Secure Fingerprint / FaceID authentication via `local_auth`.
  - Background auto-lock protection.
- **Scheduled Reminders**:
  - Daily local push notifications via `flutter_local_notifications`.
- **Local Offline Storage & Data Export**:
  - Ultra-fast SQLite database with full CRUD operations.
  - One-tap export to CSV / Excel format via `share_plus`.

---

## Architecture & Project Structure

The project follows **Clean Architecture** with a **Feature-First** modular organization:

```text
snapcost/
├── .gitignore
├── pubspec.yaml
├── README.md
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   └── app_typography.dart
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart
│   │   │   ├── date_formatter.dart
│   │   │   └── receipt_parser.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── custom_card.dart
│   │       ├── custom_text_field.dart
│   │       └── haptic_feedback.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── biometric_service.dart
│   │   ├── notification_service.dart
│   │   ├── ocr_service.dart
│   │   └── export_service.dart
│   └── features/
│       ├── auth/
│       │   └── presentation/screens/lock_screen.dart
│       ├── scanner/
│       │   └── presentation/
│       │       ├── screens/scanner_screen.dart
│       │       └── widgets/viewfinder_overlay.dart
│       ├── expenses/
│       │   ├── data/models/
│       │   │   ├── expense_model.dart
│       │   │   └── category_model.dart
│       │   ├── presentation/
│       │   │   ├── providers/expense_provider.dart
│       │   │   ├── screens/
│       │   │   │   ├── main_navigation_screen.dart
│       │   │   │   ├── dashboard_screen.dart
│       │   │   │   ├── expense_form_screen.dart
│       │   │   │   └── transaction_list_screen.dart
│       │   │   └── widgets/
│       │   │       ├── category_chart.dart
│       │   │       ├── expense_tile.dart
│       │   │       └── summary_card.dart
│       └── settings/
│           └── presentation/
│               ├── providers/settings_provider.dart
│               └── screens/settings_screen.dart
└── test/
    └── receipt_parser_test.dart
```

---

## Tech Stack & Dependencies

- **Framework**: Flutter 3.x / Dart
- **State Management**: `provider`
- **Machine Learning**: `google_mlkit_text_recognition`
- **Camera & Images**: `camera`, `image_picker`
- **Security**: `local_auth`
- **Database**: `sqflite`, `path`
- **Data Visualization**: `fl_chart`
- **Notifications**: `flutter_local_notifications`
- **Data Export**: `csv`, `share_plus`
- **Typography & Formatting**: `google_fonts`, `intl`

---

## Getting Started

### 1. Clone Repository
```bash
git clone https://github.com/Novazeb/snapcost.git
cd snapcost
```

### 2. Generate Platform Runner (if starting fresh)
```bash
flutter create .
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run Unit Tests
```bash
flutter test
```

### 5. Run the Application
```bash
# Run on connected Android / iOS device
flutter run

# Run on Chrome (Interactive preview & OCR demo simulation)
flutter run -d chrome
```

---

## License
This project is licensed under the MIT License.
