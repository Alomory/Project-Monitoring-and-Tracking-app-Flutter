# Project Monitoring & Tracking App

A Flutter application designed to help users organise projects, collaborate with team members, and monitor progress toward project completion. Users can add collaborators by email, manage project work, and track how their projects are progressing.

> **Project context:** Independently developed academic project. The application is functional but requires further refinement before it should be presented as production-ready.

## Screenshots

![Project auth](assets/screenshots/auth.png)
![Project dashboard](assets/screenshots/dashboard.png)
![Project progress tracking (Create project)](assets/screenshots/create_project.png)
![Project progress tracking (Create phase)](assets/screenshots/create_phase.png)
![Project progress tracking (Create task)](assets/screenshots/create_task.png)
![User Infromation](assets/screenshots/user_info.png)


<!-- TODO: ![Project and team management](assets/screenshots/project-team.png) add project team management image -->

## Features

- **Project organisation:** Create and manage projects.
- **Team collaboration:** Add team members using their email addresses.
- **Progress monitoring:** Track project work and monitor progress toward completion.
- **Project work management:** Organise project activities and follow their completion status.
- **Cloud data storage:** Uses Firebase to store application data.

The exact project, phase, and task workflows should be checked against the current application build before adding more detailed feature claims.

## My Contribution

I developed the application independently, including the Flutter application structure, project-management workflows, team-related functionality, progress monitoring, and Firebase data integration.

The project still needs adjustments and refinement. It is presented here as an academic project rather than a production-ready product.

## Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **Data storage:** Firebase

## Getting Started

### Prerequisites

- Flutter SDK installed and configured.
- An Android emulator or physical device.
- Access to the Firebase project used by the application.

### Installation

The Flutter application is located in the `project_monitoring_and_tracking` directory:

```bash
cd project_monitoring_and_tracking
flutter pub get
```

### Run

```bash
flutter run
```

### Firebase Configuration

Configure the Firebase project and the platform-specific Firebase settings required by the application before running it. Use an authorised Firebase project for local development. Do not commit service-account credentials, private keys, or other secrets.

## Repository Layout

```text
.
├── project_monitoring_and_tracking/  # Flutter application
├── assets/
│   └── screenshots/                  # Add application screenshots here
└── README.md
```

Supporting academic documents may also be present in the repository.

## Project Status

This is an independently developed academic project that may need further UI, workflow, or technical refinements. Review the current source and test the application before using it as a production system.

## License

Add a `LICENSE` file if you intend to grant others permission to use, modify, or distribute this code. Until a licence is specified, do not assume that public visibility grants reuse rights.
