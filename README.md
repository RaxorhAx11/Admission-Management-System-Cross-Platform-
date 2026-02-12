# Admission Management System (Cross Platform)

A mid-level Flutter app for admission management with Firebase backend. Supports **Student** and **Admin** roles.

## Tech Stack

- **Frontend:** Flutter (Android + iOS)
- **Backend:** Firebase Auth, Cloud Firestore, Firebase Storage

## Git & GitHub

To put this project on GitHub:

1. Initialize Git in this folder:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```
2. Create a new empty repository on GitHub (no README, .gitignore, or license).
3. Add the remote and push:
   ```bash
   git remote add origin https://github.com/<your-username>/<your-repo>.git
   git push -u origin main
   ```
4. This project already includes:
   - A `.gitignore` configured for Flutter, Android, iOS, and environment files (e.g. `google-services.json`, `.env`).
   - A `.gitattributes` file for consistent line endings and binary assets.
   - A GitHub Actions workflow at `.github/workflows/flutter-ci.yml` that runs `flutter analyze` and `flutter test` on pushes and pull requests to `main`.

## Setup

1. **Install Flutter** and ensure it's in PATH.
2. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com).
3. **Add Android & iOS apps** in Firebase and download config files:
   - Android: place `google-services.json` in `android/app/`
   - iOS: place `GoogleService-Info.plist` in `ios/Runner/`
4. **Generate Firebase options** (optional, for default config):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   If you skip this, ensure you initialize Firebase in `main.dart` with your project config.
5. **Install dependencies:**
   ```bash
   flutter pub get
   ```
6. **Run:**
   ```bash
   flutter run
   ```

## Admin Accounts

Admin users are stored in Firestore under `users` with `role: 'admin'`. To create the first admin:

1. Register a student account from the app (to get a Firebase Auth UID).
2. In Firebase Console → Firestore → `users` collection, find the document with that UID and edit the `role` field from `student` to `admin`.  
   Or create a new document with a custom UID (must match a Firebase Auth user after you sign in with that email/password).

Then log in with that email/password; the app will treat the user as admin and show the Admin Dashboard.

## Firestore Index (if required)

If you see an error when loading "My Applications" (student) or application list (admin), Firestore may ask you to create a composite index. Use the link in the error message to create the index in Firebase Console, or create an index on:

- Collection: `applications`
- Fields: `studentId` (Ascending), `appliedDate` (Descending)

## Project Structure

- `lib/core/` – Theme, constants
- `lib/models/` – User, Course, Application models
- `lib/services/` – Auth, Firestore, Storage
- `lib/providers/` – Provider state (auth, courses, applications)
- `lib/screens/` – All app screens
- `lib/widgets/` – Reusable UI components

## Firestore Collections

- **users** – uid, name, email, role
- **courses** – courseId, courseName, duration, fees, eligibility, seats
- **applications** – applicationId, studentId, courseId, additionalDetails, documentUrls, status, remarks, appliedDate

## License

This project is licensed under the MIT License – see the `LICENSE` file for details. Replace `[Your Name]` in the license with your name or organization before publishing.

