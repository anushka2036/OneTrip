# Flutter Architecture

## Main Structure

lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
│
├── models/
│
├── services/
│
├── screens/
│   ├── auth/
│   ├── home/
│   ├── trips/
│   ├── planner/
│   ├── expenses/
│   ├── community/
│   └── profile/
│
├── widgets/
│
└── routes/

## Main Responsibilities

### Screens

Contain page-level UI.

### Widgets

Contain reusable UI components.

### Models

Represent API/database data.

### Services

Handle:

- API communication
- Authentication
- Maps
- Notifications

### Core

Contains:

- Theme
- Constants
- Utility functions
- Common configuration