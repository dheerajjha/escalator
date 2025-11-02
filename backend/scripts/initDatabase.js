const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

// Ensure database directory exists
const dbDir = path.join(__dirname, '../database');
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const dbPath = path.join(dbDir, 'escalator.db');
const db = new Database(dbPath);

console.log('📦 Initializing Escalator database...');

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Create tables
db.exec(`
  -- Users table
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    role TEXT CHECK(role IN ('junior', 'senior', 'principal')) DEFAULT 'senior',
    fcm_token TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  -- Work items table
  CREATE TABLE IF NOT EXISTS work_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    dependency_poc TEXT NOT NULL,
    poc_email TEXT,
    current_stage TEXT CHECK(current_stage IN ('active', 'day2_nudge', 'day4_second_nudge', 'week1_call', 'manager_escalation', 'resolved')) DEFAULT 'active',
    impact TEXT,
    manager_name TEXT,
    manager_email TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    stage_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );

  -- Escalation history table
  CREATE TABLE IF NOT EXISTS escalation_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    work_item_id INTEGER NOT NULL,
    from_stage TEXT,
    to_stage TEXT NOT NULL,
    action_taken TEXT NOT NULL,
    notes TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (work_item_id) REFERENCES work_items(id) ON DELETE CASCADE
  );

  -- Standup updates table
  CREATE TABLE IF NOT EXISTS standup_updates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    work_item_id INTEGER NOT NULL,
    update_text TEXT NOT NULL,
    date DATE DEFAULT (DATE('now')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (work_item_id) REFERENCES work_items(id) ON DELETE CASCADE
  );

  -- Reminders table (for tracking when to send notifications)
  CREATE TABLE IF NOT EXISTS reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    work_item_id INTEGER NOT NULL,
    reminder_type TEXT CHECK(reminder_type IN ('nudge_day2', 'second_nudge_day4', 'setup_call_week1', 'escalate_manager')) NOT NULL,
    scheduled_for DATETIME NOT NULL,
    sent BOOLEAN DEFAULT 0,
    sent_at DATETIME,
    FOREIGN KEY (work_item_id) REFERENCES work_items(id) ON DELETE CASCADE
  );

  -- Create indexes for better performance
  CREATE INDEX IF NOT EXISTS idx_work_items_user ON work_items(user_id);
  CREATE INDEX IF NOT EXISTS idx_work_items_stage ON work_items(current_stage);
  CREATE INDEX IF NOT EXISTS idx_escalation_history_item ON escalation_history(work_item_id);
  CREATE INDEX IF NOT EXISTS idx_standup_updates_item ON standup_updates(work_item_id);
  CREATE INDEX IF NOT EXISTS idx_reminders_scheduled ON reminders(scheduled_for, sent);
`);

console.log('✅ Database tables created successfully!');
console.log(`📍 Database location: ${dbPath}`);

db.close();
