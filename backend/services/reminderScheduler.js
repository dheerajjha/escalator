const cron = require('node-cron');
const db = require('../config/database');
const notificationService = require('./notificationService');

// Check for due reminders every hour
const CRON_SCHEDULE = '0 * * * *'; // Every hour at minute 0

function checkAndSendReminders() {
  try {
    console.log('🔔 Checking for due reminders...');

    // Get all unsent reminders that are due
    const dueReminders = db.prepare(`
      SELECT r.*, w.title, w.dependency_poc, w.user_id, w.current_stage
      FROM reminders r
      JOIN work_items w ON r.work_item_id = w.id
      WHERE r.sent = 0
        AND r.scheduled_for <= datetime('now')
        AND w.current_stage != 'resolved'
      ORDER BY r.scheduled_for ASC
    `).all();

    if (dueReminders.length === 0) {
      console.log('📭 No due reminders found');
      return;
    }

    console.log(`📬 Found ${dueReminders.length} due reminder(s)`);

    // Process each reminder
    dueReminders.forEach(reminder => {
      try {
        // Get user info for FCM token
        const user = db.prepare('SELECT * FROM users WHERE id = ?').get(reminder.user_id);

        const reminderMessages = {
          'nudge_day2': `Time to nudge ${reminder.dependency_poc} offline about "${reminder.title}" and add standup update`,
          'second_nudge_day4': `Second nudge needed for "${reminder.title}" - Call out in standup`,
          'setup_call_week1': `It's been a week! Setup a call with ${reminder.dependency_poc} for "${reminder.title}"`,
          'escalate_manager': `Time to escalate "${reminder.title}" to manager - POC hasn't responded`
        };

        const message = reminderMessages[reminder.reminder_type] || `Reminder for "${reminder.title}"`;

        // Send notification
        if (user && user.fcm_token) {
          notificationService.sendPushNotification(
            user.fcm_token,
            'Escalation Reminder',
            message,
            { workItemId: reminder.work_item_id.toString(), type: 'reminder' }
          );
        }

        // Mark reminder as sent
        const updateStmt = db.prepare(`
          UPDATE reminders
          SET sent = 1, sent_at = CURRENT_TIMESTAMP
          WHERE id = ?
        `);
        updateStmt.run(reminder.id);

        console.log(`✅ Sent reminder for work item #${reminder.work_item_id}: ${reminder.reminder_type}`);
      } catch (error) {
        console.error(`❌ Failed to process reminder #${reminder.id}:`, error);
      }
    });
  } catch (error) {
    console.error('❌ Error in reminder scheduler:', error);
  }
}

// Start the scheduler
function start() {
  console.log('🚀 Starting reminder scheduler...');
  console.log(`⏰ Schedule: ${CRON_SCHEDULE} (every hour)`);

  // Run immediately on start
  checkAndSendReminders();

  // Schedule recurring checks
  cron.schedule(CRON_SCHEDULE, checkAndSendReminders);
}

module.exports = { start, checkAndSendReminders };
