# Project Monitoring & Tracking App

A Flutter application for organising projects, collaborating with team members, and monitoring project progress. Users can add teammates by email, manage project work, and track completion through the app.

## Screenshots

![Project auth](assets/screenshots/auth.png)

![Project dashboard](assets/screenshots/dashboard.png)

![Project progress tracking (Create project)](assets/screenshots/create_project.png)

![Project progress tracking (Create phase)](assets/screenshots/create_phase.png)

![Project progress tracking (Create task)](assets/screenshots/create_task.png)

<!-- ![User Infromation](assets/screenshots/user_info.png) -->
<!-- <p align="center">
  <img src="assets/screenshots/dashboard.png" alt="Project dashboard" width="240" />
  <img src="assets/screenshots/project-team.png" alt="Project team" width="240" />
  <img src="assets/screenshots/project-progress.png" alt="Project progress" width="240" />
</p> -->

## Features

- Create and manage projects.
- Add team members using their email addresses.
- Organise and complete project work.
- Monitor project progress and completion.
- Store application data with Firebase.

## Technology

- Flutter and Dart
- Firebase

## Run locally

**Requirements:** Flutter SDK, an Android or iOS development environment, and access to the Firebase project configuration used by the app.

From the project root:

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

Configure Firebase for the target platform before running the application. Review database security rules before using real user data, and keep private credentials and signing keys out of version control.

## Project structure

The Flutter application is organised around data access, models, screens, themes, and reusable widgets. Images and screenshots are stored separately under `assets/`.

```text
lib/
├── data/
├── models/
├── screens/
├── themes/
└── widgets/

assets/
├── images/
└── screenshots/
```

## License

Distributed under the MIT License. See [LICENSE](LICENSE).
