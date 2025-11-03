const cron = require('node-cron');
const db = require('../config/database');
const notificationService = require('./notificationService');

// Check for due reminders every hour
const CRON_SCHEDULE = '0 * * * *'; // Every hour at minute 0

// Send task summary twice daily: 9 AM and 5 PM IST (Indian Standard Time)
// IST is UTC+5:30, so 9 AM IST = 3:30 AM UTC, 5 PM IST = 11:30 AM UTC
const DAILY_SUMMARY_SCHEDULE_MORNING = '30 3 * * *'; // 9 AM IST (3:30 AM UTC)
const DAILY_SUMMARY_SCHEDULE_EVENING = '30 11 * * *'; // 5 PM IST (11:30 AM UTC)

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

// Send daily task summary to all users
function sendDailySummary() {
  try {
    console.log('📊 Sending daily task summary...');

    // Get all users with FCM tokens
    const users = db.prepare(`
      SELECT id, username, display_name, fcm_token
      FROM users
      WHERE fcm_token IS NOT NULL
    `).all();

    if (users.length === 0) {
      console.log('📭 No users with FCM tokens found');
      return;
    }

    users.forEach(user => {
      try {
        // Get user's pending work items
        const workItems = db.prepare(`
          SELECT
            COUNT(*) as total_pending,
            SUM(CASE WHEN current_stage = 'in_progress' THEN 1 ELSE 0 END) as in_progress,
            SUM(CASE WHEN current_stage = 'blocked' THEN 1 ELSE 0 END) as blocked
          FROM work_items
          WHERE user_id = ? AND current_stage != 'resolved'
        `).get(user.id);

        // Only send notification if user has pending tasks
        if (workItems && workItems.total_pending > 0) {
          let message = `You have ${workItems.total_pending} pending task${workItems.total_pending > 1 ? 's' : ''}`;

          if (workItems.in_progress > 0) {
            message += `, ${workItems.in_progress} in progress`;
          }
          if (workItems.blocked > 0) {
            message += `, ${workItems.blocked} blocked`;
          }

          notificationService.sendPushNotification(
            user.fcm_token,
            'Daily Task Summary',
            message,
            { type: 'daily_summary' }
          );

          console.log(`✅ Sent daily summary to ${user.username}: ${workItems.total_pending} tasks`);
        }
      } catch (error) {
        console.error(`❌ Failed to send summary to user #${user.id}:`, error);
      }
    });
  } catch (error) {
    console.error('❌ Error in daily summary scheduler:', error);
  }
}

// Start the scheduler
function start() {
  console.log('🚀 Starting reminder scheduler...');
  console.log(`⏰ Reminder schedule: ${CRON_SCHEDULE} (every hour)`);
  console.log(`⏰ Daily summary schedule: 9 AM and 5 PM IST (Indian Standard Time)`);

  // Run immediately on start
  checkAndSendReminders();

  // Schedule recurring checks for reminders
  cron.schedule(CRON_SCHEDULE, checkAndSendReminders);

  // Schedule daily summaries - twice a day (9 AM and 5 PM)
  cron.schedule(DAILY_SUMMARY_SCHEDULE_MORNING, sendDailySummary);
  cron.schedule(DAILY_SUMMARY_SCHEDULE_EVENING, sendDailySummary);
}

module.exports = { start, checkAndSendReminders, sendDailySummary };
