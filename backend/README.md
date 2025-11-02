# Escalator Backend

Node.js + Express backend for the Escalator work tracking and escalation system.

## Features

- **RESTful API** for work item management
- **SQLite database** for lightweight, file-based storage
- **Escalation tracking** with time-based stages
- **Reminder scheduler** using node-cron
- **FCM push notifications** (placeholder - requires Firebase setup)

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create environment file:
```bash
cp .env.example .env
```

3. Initialize the database:
```bash
npm run init-db
```

4. Start the server:
```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

## API Endpoints

### Users
- `POST /api/users/onboard` - Create new user with unique username
- `GET /api/users/:id` - Get user by ID
- `GET /api/users` - Get all users
- `PUT /api/users/:id/fcm-token` - Update FCM token for notifications

### Work Items
- `POST /api/work-items` - Create new work item
- `GET /api/work-items/user/:userId` - Get all work items for a user
- `GET /api/work-items/:id` - Get single work item with history
- `PUT /api/work-items/:id` - Update work item
- `DELETE /api/work-items/:id` - Delete work item
- `POST /api/work-items/:id/resolve` - Mark work item as resolved

### Escalations
- `POST /api/escalations/:id/escalate` - Escalate work item to next stage
- `GET /api/escalations/:id/history` - Get escalation history
- `GET /api/escalations/reminders/pending` - Get pending reminders

### Standup Updates
- `POST /api/standups` - Add standup update
- `GET /api/standups/work-item/:workItemId` - Get updates for a work item
- `GET /api/standups/user/:userId` - Get all updates for a user
- `GET /api/standups/date/:date` - Get updates by date
- `DELETE /api/standups/:id` - Delete standup update

## Escalation Stages

1. **Active** - Initial stage, waiting for response
2. **Day 2 Nudge** - Nudge POC offline + standup update
3. **Day 4 Second Nudge** - Second nudge + call out in standup
4. **Week 1 Call** - Setup call with POC
5. **Manager Escalation** - Escalate to manager with full context
6. **Resolved** - Work item completed

## Firebase Cloud Messaging (FCM) Setup

To enable push notifications:

1. Create a Firebase project at https://console.firebase.google.com
2. Download the service account JSON file
3. Save it as `config/firebase-service-account.json`
4. Install firebase-admin: `npm install firebase-admin`
5. Uncomment FCM code in `services/notificationService.js`

## Database Schema

- **users** - User accounts with roles and FCM tokens
- **work_items** - Work items with escalation tracking
- **escalation_history** - Audit trail of all escalations
- **standup_updates** - Daily standup notes
- **reminders** - Scheduled reminder notifications

## License

MIT
