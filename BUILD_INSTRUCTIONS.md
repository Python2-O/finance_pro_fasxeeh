# Finance Pro – FasXeeH
## Complete Build Instructions

---

## Prerequisites

### 1. Install Flutter
```bash
# Download Flutter SDK (Latest Stable)
# https://docs.flutter.dev/get-started/install/linux

# Add to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Verify
flutter doctor
```

### 2. Install Android Studio
- Download: https://developer.android.com/studio
- Install Android SDK (API 33+)
- Install Android Emulator or connect a physical device (Android 6.0+)

### 3. Accept Android Licenses
```bash
flutter doctor --android-licenses
```

---

## Project Setup

### Step 1: Get the project
```bash
# Navigate to project
cd finance_pro
```

### Step 2: Create required asset directories
```bash
mkdir -p assets/images assets/animations assets/fonts
```

### Step 3: Add Poppins fonts (required)
Download Poppins fonts from Google Fonts:
https://fonts.google.com/specimen/Poppins

Download these weights and place in `assets/fonts/`:
- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

### Step 4: Install dependencies
```bash
flutter pub get
```

### Step 5: Verify setup
```bash
flutter doctor
flutter devices
```

---

## Running the App

### Debug Mode (for development/testing)
```bash
# List connected devices
flutter devices

# Run on a specific device
flutter run -d <device_id>

# Run on first available device
flutter run
```

### Run on Emulator
```bash
# List emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Then run
flutter run
```

---

## Building the APK

### Debug APK (for testing, no signing required)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for distribution)

#### Step 1: Generate a signing key
```bash
keytool -genkey -v \
  -keystore ~/finance_pro_keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias finance_pro \
  -storepass YourStorePassword \
  -keypass YourKeyPassword \
  -dname "CN=FasXeeH, OU=Finance, O=FasXeeH, L=City, S=State, C=PK"
```

#### Step 2: Configure signing in android/key.properties
Create file `android/key.properties`:
```properties
storePassword=YourStorePassword
keyPassword=YourKeyPassword
keyAlias=finance_pro
storeFile=/path/to/finance_pro_keystore.jks
```

#### Step 3: Update android/app/build.gradle
Add before `android {`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Inside `android { buildTypes { release {`:
```groovy
signingConfig signingConfigs.release
```

Add inside `android {`:
```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

#### Step 4: Build release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Installing on Device

### Via ADB (USB debugging)
```bash
# Enable USB debugging on your Android phone
# Connect via USB

adb devices  # Verify device detected
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Direct APK Transfer
1. Copy `app-debug.apk` to your phone
2. Enable "Install from unknown sources" in Settings
3. Tap the APK file to install

---

## App Architecture Overview

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── constants/app_constants.dart   # App-wide constants + Excel seed data
│   ├── theme/app_theme.dart           # Material 3 Dark/Light themes
│   └── utils/formatters.dart         # PKR currency + date formatting
├── data/
│   ├── database/database_helper.dart  # SQLite with auto-seed from Excel data
│   ├── models/                        # Data models (Month, Income, Expense, Bill, Loan)
│   └── repositories/                 # Data access layer
└── presentation/
    ├── providers/                     # State management (ChangeNotifier)
    ├── screens/
    │   ├── auth/                      # Splash, PIN create, PIN login
    │   ├── dashboard/                 # Main shell + dashboard
    │   ├── income/                    # Income management
    │   ├── expense/                   # Daily expenses + bills tabs
    │   ├── loans/                     # Borrowed/lent loan tracker
    │   ├── analytics/                 # Charts (pie, bar, line)
    │   ├── reports/                   # Reports + PDF export
    │   └── settings/                  # PIN change, biometric, theme
    └── widgets/                       # Reusable UI components
```

---

## Database Schema

### months
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Month name (June, July...) |
| year | INTEGER | Year (2025) |
| month_number | INTEGER | 1–12 |
| created_at | TEXT | ISO 8601 |

### income
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| month_id | INTEGER FK | → months.id |
| category | TEXT | Salary, OT, Extra Income... |
| amount | REAL | |
| remarks | TEXT | Optional |
| date | TEXT | |
| created_at | TEXT | |

### expenses
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| month_id | INTEGER FK | → months.id |
| category | TEXT | Food, Transport, Misc... |
| sub_category | TEXT | Optional refinement |
| amount | REAL | |
| day | INTEGER | Day of month |
| date | TEXT | |
| remarks | TEXT | Optional |
| created_at | TEXT | |

### bills
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| month_id | INTEGER FK | → months.id |
| category | TEXT | Grocery, Electricity... |
| amount | REAL | |
| remarks | TEXT | Optional |
| created_at | TEXT | |

### loans
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| type | TEXT | 'borrowed' or 'lent' |
| person | TEXT | Name of person |
| original_amount | REAL | |
| paid_or_received | REAL | |
| date | TEXT | Optional |
| remarks | TEXT | Optional |
| is_settled | INTEGER | 0 or 1 |
| created_at | TEXT | |

---

## Pre-loaded Excel Data

The app automatically imports your Excel data on first launch:

### June 2025 Income
- Salary: ₨ 74,630
- Extra Income: ₨ 10,000 (Lent from Hasnain)
- **Total: ₨ 84,630**

### June 2025 Bills
- Grocery: ₨ 16,000
- Loan Repayment: ₨ 15,750
- Wifi: ₨ 2,000
- Wife: ₨ 8,463
- **Total Bills: ₨ 42,213**

### June 2025 Daily Expenses (7 entries)
Day 26–1 with miscellaneous expenses totaling ₨ 36,100

### Loans – Borrowed
| Person | Amount | Paid | Pending |
|--------|--------|------|---------|
| Chaveet | ₨ 4,700 | ₨ 0 | ₨ 4,700 |
| Hasnain | ₨ 10,000 | ₨ 0 | ₨ 10,000 |

### Loans – Lent
| Person | Amount | Received | Pending |
|--------|--------|----------|---------|
| Hasnain | ₨ 1,000 | ₨ 0 | ₨ 1,000 |
| Abbas | ₨ 1,600 | ₨ 0 | ₨ 1,600 |

---

## Security Features

- **4-digit PIN** — Stored encrypted via flutter_secure_storage (AES encryption, Android Keystore)
- **Biometric unlock** — Fingerprint via local_auth (Android BiometricPrompt API)
- **Change PIN** — Verify current → set new → confirm new
- **Auto-lock** — Lock button in Settings returns to PIN screen
- **minSdkVersion 23** — Ensures BiometricPrompt is available on all target devices

---

## Troubleshooting

### `flutter doctor` shows issues
```bash
# Missing Android SDK
# Install Android Studio, then:
flutter config --android-sdk /path/to/android/sdk

# Missing licenses
flutter doctor --android-licenses
```

### Build fails with Gradle error
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

### Font missing error
Make sure all 4 Poppins font files are in `assets/fonts/`. The app uses Google Fonts as fallback if files are missing.

### Database issues on re-install
The SQLite database is fresh on each clean install. Pre-seeded Excel data loads automatically from `AppConstants`.

---

## Feature Summary

| Feature | Status |
|---------|--------|
| 4-digit PIN security | ✅ |
| Biometric (fingerprint) unlock | ✅ |
| Change PIN | ✅ |
| Dark mode / Light mode | ✅ |
| Month management (unlimited) | ✅ |
| June/July/August pre-loaded | ✅ |
| Income tracking (Salary/OT/Extra/Custom) | ✅ |
| Daily expense tracking | ✅ |
| Monthly bills tracker | ✅ |
| Loan tracker (Borrowed + Lent) | ✅ |
| Dashboard with summary cards | ✅ |
| Analytics (pie, bar, line charts) | ✅ |
| Monthly reports | ✅ |
| PDF export & share | ✅ |
| SQLite persistence | ✅ |
| Material Design 3 | ✅ |
| PKR currency formatting | ✅ |
| Smooth animations | ✅ |

---

*Finance Pro – FasXeeH · Track · Save · Grow*
