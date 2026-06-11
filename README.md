# Kernel

Kernel is a mobile learning app for bite-sized programming courses. Users sign in, pick a course, complete interactive lessons (MCQs, code-fill exercises), and track progress across units.

The app is functional end-to-end on iOS. A live Supabase database backs auth, course structure, and user progress. Lesson content is bundled in the repo. See screenshots in `/docs/screenshots/`.

---

## What Works

- Google Sign-In and Apple Sign-In (via Supabase Auth)
- Onboarding flow for new users
- Course home screen with units and lesson list (Python course)
- Interactive lesson reader (content blocks, MCQs, code-fill)
- Lesson completion and progress tracking
- User profile (avatar, display name, account deletion)
- Light / dark theme

## Tech Stack


| Layer            | Technology                             |
| ---------------- | -------------------------------------- |
| Frontend         | Flutter (Dart)                         |
| State management | Provider                               |
| Backend / DB     | Supabase (PostgreSQL + Auth + Storage) |
| Auth             | Google Sign-In, Sign in with Apple     |


---

## For Reviewers

This is a **mobile app** — it is designed to run on iOS (Simulator or device). Local setup requires Xcode and Flutter.

**You do not need to run the app to review this submission.** Screenshots in `/docs/screenshots/` demonstrate the working flows. The ERD and sample data are submitted separately.

The app connects to a **hosted Supabase project** over HTTPS (no local database setup required). Credentials are in `lib/config/supabase_config.dart` (anon key only — protected by Row Level Security).

---

## Run Locally

**Prerequisites:** macOS, Xcode, Flutter SDK 3.7+, CocoaPods, internet connection.

```bash
git clone git@github.com:hrishav-aryal/kernel.git
cd kernel

flutter pub get
cd ios && pod install && cd ..

open -a Simulator   # or connect a physical iPhone
flutter run
```

**Alternative (macOS desktop):**

```bash
flutter run -d macos
```

---

---

## Project Structure

```
lib/
  screens/       # UI (auth, home, profile)
  providers/     # State management
  services/      # Business logic
  repositories/  # Data access
  models/        # Data models
  config/        # Supabase configuration
assets/
  courses/       # Lesson JSON content
  avatars/       # User avatar images
  icon/          # App icons and UI assets
```

