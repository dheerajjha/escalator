# Escalator Web Frontend

React-based web application for the Escalator work tracking and escalation system.

## Features

- **Onboarding Flow** - Simple name input with automatic unique username generation
- **Kanban Board** - Visual board showing work items across 6 escalation stages
- **Work Item Management** - Create, update, and track work items
- **Escalation Tracking** - Manual escalation with visual history timeline
- **Standup Updates** - Add and view daily standup notes for each work item
- **Responsive Design** - Works on desktop and mobile browsers

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment (optional):
Create `.env` file:
```
VITE_API_URL=http://194.195.117.157:5230/api
```

3. Start development server:
```bash
npm run dev
```

The app will be available at http://localhost:3001 (development) or http://194.195.117.157:5231 (production)

4. Build for production:
```bash
npm run build
```

## Project Structure

```
src/
├── components/          # React components
│   ├── Onboarding.jsx      # User onboarding screen
│   ├── Dashboard.jsx       # Main dashboard
│   ├── KanbanBoard.jsx     # Kanban board view
│   ├── CreateWorkItemModal.jsx
│   └── WorkItemDetail.jsx  # Detailed work item view
├── services/
│   └── api.js          # API client for backend
├── App.jsx             # Main app component with routing
├── App.css             # Global styles
├── main.jsx            # App entry point
└── index.css           # Base CSS variables
```

## Escalation Stages

1. **Active** - Initial stage, waiting for response
2. **Day 2 Nudge** - Nudge POC offline + standup update
3. **Day 4 Second Nudge** - Second nudge + call out in standup
4. **Week 1 Call** - Setup call with POC
5. **Manager Escalation** - Escalate to manager with context
6. **Resolved** - Work item completed

## User Flow

1. **Onboarding**: Enter name → Get unique username → Choose role
2. **Dashboard**: View all work items in Kanban board
3. **Create Work Item**: Add title, description, POC, impact, etc.
4. **Track Progress**: Work items automatically get reminder notifications
5. **Escalate**: Manually move items through escalation stages
6. **Standup Updates**: Add daily notes visible to the team
7. **Resolve**: Mark items as complete when unblocked

## Technologies

- **React 18** - UI framework
- **React Router** - Client-side routing
- **Vite** - Build tool and dev server
- **Axios** - HTTP client
- **date-fns** - Date formatting

## License

MIT
