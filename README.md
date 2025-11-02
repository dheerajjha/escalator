# Escalator

A comprehensive work tracking and escalation management system with web and mobile interfaces.

## Project Overview

Escalator helps engineers systematically track blocked work items and follow structured escalation patterns. It implements a time-based escalation workflow based on engineering best practices.

## Escalation Workflow

The system follows this escalation pattern:

1. **Active** - Initial stage, waiting for dependency/POC response
2. **Day 2 - Nudge Offline** - After 2 days: Nudge POC offline + add standup update
3. **Day 4 - Second Nudge** - After 4 days: Second nudge + call out in standup
4. **Week 1 - Setup Call** - After 1 week: Schedule call with POC to get answer
5. **Manager Escalation** - If call not joined: Escalate to manager with full context
6. **Resolved** - Work item completed

## Project Structure

```
Escalator/
├── backend/       # Node.js + Express + SQLite API server
├── web/           # React web application
└── app/           # Flutter mobile application
```

## Quick Start

### Backend Setup

```bash
cd backend
npm install
npm run init-db
npm run dev
```

Backend runs on http://localhost:3000

### Web Frontend

```bash
cd web
npm install
npm run dev
```

Web app runs on http://localhost:3001

### Mobile App

```bash
cd app
flutter pub get

# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

## Features

### Core Features
- ✅ User onboarding with unique username generation
- ✅ Work item creation and tracking
- ✅ Visual Kanban board across escalation stages
- ✅ Manual escalation with smart time-based reminders
- ✅ Standup update notes
- ✅ Escalation history tracking
- ✅ Role-based workflows (Junior/Senior/Principal Engineer)

### Technical Features
- ✅ RESTful API backend
- ✅ SQLite database with migrations
- ✅ React web interface
- ✅ Flutter mobile app (iOS + Android)
- ✅ State management with Provider
- ✅ Push notifications (FCM) - requires Firebase setup
- ✅ Responsive design
- ✅ Offline support (mobile app)

## Technology Stack

### Backend
- Node.js + Express.js
- SQLite with better-sqlite3
- node-cron for scheduled tasks
- CORS enabled for cross-origin requests

### Web
- React 18
- React Router for navigation
- Vite for build tooling
- Axios for API calls
- date-fns for date formatting

### Mobile
- Flutter (Dart)
- Provider for state management
- Firebase Cloud Messaging (optional)
- SharedPreferences for local storage

## Database Schema

### Tables
- **users** - User accounts with roles and FCM tokens
- **work_items** - Work items with current escalation stage
- **escalation_history** - Complete audit trail
- **standup_updates** - Daily standup notes
- **reminders** - Scheduled notification triggers

## API Documentation

See `backend/README.md` for detailed API endpoints.

Key endpoints:
- `POST /api/users/onboard` - Create new user
- `POST /api/work-items` - Create work item
- `GET /api/work-items/user/:userId` - Get user's work items
- `POST /api/escalations/:id/escalate` - Escalate to next stage
- `POST /api/work-items/:id/resolve` - Mark as resolved
- `POST /api/standups` - Add standup update

## Environment Setup

### Backend (.env)
```
PORT=3000
NODE_ENV=development
DB_PATH=./database/escalator.db
```

### Web (.env)
```
VITE_API_URL=http://localhost:3000/api
```

### Mobile
Edit `lib/services/api_service.dart` to set your API endpoint.

## Firebase Setup (Optional for Push Notifications)

1. Create Firebase project at https://console.firebase.google.com
2. Add iOS and Android apps
3. Download configuration files:
   - iOS: `GoogleService-Info.plist`
   - Android: `google-services.json`
4. Backend: Download service account JSON for firebase-admin
5. Install: `npm install firebase-admin` in backend

The app works without Firebase, but notifications will be disabled.

## Development

### Running All Services

Terminal 1 - Backend:
```bash
cd backend && npm run dev
```

Terminal 2 - Web:
```bash
cd web && npm run dev
```

Terminal 3 - Mobile:
```bash
cd app && flutter run
```

### Building for Production

Backend:
```bash
cd backend && npm start
```

Web:
```bash
cd web && npm run build
```

Mobile:
```bash
cd app && flutter build ios --release
cd app && flutter build apk --release
```

## Testing

### Manual Testing Flow

1. **Onboarding**: Enter name → receive unique username
2. **Create Work Item**: Add title, POC, impact details
3. **Dashboard**: View items on Kanban board
4. **Escalate**: Move through escalation stages
5. **Standup Updates**: Add daily notes
6. **Resolve**: Mark items as complete

### Database Verification

```bash
sqlite3 backend/database/escalator.db
.tables
SELECT * FROM work_items;
SELECT * FROM escalation_history;
```

## Project Architecture

### Backend (MVC Pattern)
- `routes/` - Express route handlers
- `config/` - Database configuration
- `services/` - Business logic (scheduler, notifications)
- `scripts/` - Database initialization

### Web (Component-Based)
- `components/` - React components
- `services/` - API client
- `App.jsx` - Main app with routing

### Mobile (Clean Architecture)
- `models/` - Data models
- `providers/` - State management
- `screens/` - UI screens
- `widgets/` - Reusable components
- `services/` - API and notifications

## License

MIT

## Author

Created for systematic work tracking and escalation management in engineering teams.
