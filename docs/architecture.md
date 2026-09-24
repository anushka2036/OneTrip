# OneTrip System Architecture

## 1. High-Level Architecture

Flutter Mobile Application
        |
        | REST API
        ↓
FastAPI Backend
        |
        ├── MongoDB Atlas
        ├── Firebase Authentication
        ├── Firebase Cloud Messaging
        ├── Google Maps Platform
        ├── OCR Service/Library
        ├── LLM API
        └── Scikit-learn

## 2. Main Components

### Flutter Application

Responsible for:

- User interface
- Navigation
- Forms
- Maps UI
- Itinerary display
- Expense dashboard
- Community feed
- Notifications UI

### FastAPI Backend

Responsible for:

- API endpoints
- Business logic
- Authentication verification
- Trip management
- Ticket processing
- AI planner
- Expense analysis
- Community functionality

### MongoDB Atlas

Stores:

- Users
- Trips
- Tickets
- Itineraries
- Expenses
- Community posts

### AI Layer

Scikit-learn:

- Recommendation
- Similarity analysis
- Preference-based ranking

LLM:

- Ticket information extraction
- Itinerary generation
- Trip summaries
- Itinerary adaptation

### Google Maps Platform

Provides:

- Maps
- Places
- Geocoding
- Routes/directions

### Firebase

Firebase Authentication:

- User authentication

Firebase Cloud Messaging:

- Travel reminders