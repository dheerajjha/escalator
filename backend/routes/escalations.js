const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Stage progression mapping
const STAGE_PROGRESSION = {
  'active': 'day2_nudge',
  'day2_nudge': 'day4_second_nudge',
  'day4_second_nudge': 'week1_call',
  'week1_call': 'manager_escalation',
  'manager_escalation': 'manager_escalation' // Final stage
};

const STAGE_ACTIONS = {
  'day2_nudge': 'Nudge POC offline + standup update',
  'day4_second_nudge': 'Second nudge + call out in standup',
  'week1_call': 'Setup call with POC',
  'manager_escalation': 'Escalate to manager with full context'
};

// Escalate work item to next stage
router.post('/:id/escalate', (req, res) => {
  try {
    const { notes } = req.body;

    const workItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(req.params.id);

    if (!workItem) {
      return res.status(404).json({ error: 'Work item not found' });
    }

    if (workItem.current_stage === 'resolved') {
      return res.status(400).json({ error: 'Cannot escalate resolved item' });
    }

    const currentStage = workItem.current_stage;
    const nextStage = STAGE_PROGRESSION[currentStage];

    if (!nextStage) {
      return res.status(400).json({ error: 'Invalid current stage' });
    }

    // Update work item stage
    const stmt = db.prepare(`
      UPDATE work_items
      SET current_stage = ?,
          stage_updated_at = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);
    stmt.run(nextStage, req.params.id);

    // Add history entry
    const historyStmt = db.prepare(`
      INSERT INTO escalation_history (work_item_id, from_stage, to_stage, action_taken, notes)
      VALUES (?, ?, ?, ?, ?)
    `);
    historyStmt.run(
      req.params.id,
      currentStage,
      nextStage,
      STAGE_ACTIONS[nextStage] || 'Escalated to next stage',
      notes
    );

    // Schedule next reminder if not at final stage
    if (nextStage !== 'manager_escalation') {
      const reminderTypes = {
        'day2_nudge': { type: 'second_nudge_day4', days: 2 },
        'day4_second_nudge': { type: 'setup_call_week1', days: 3 }, // Total 7 days from start
        'week1_call': { type: 'escalate_manager', days: 1 }
      };

      const reminderInfo = reminderTypes[nextStage];
      if (reminderInfo) {
        const reminderStmt = db.prepare(`
          INSERT INTO reminders (work_item_id, reminder_type, scheduled_for)
          VALUES (?, ?, datetime('now', '+${reminderInfo.days} days'))
        `);
        reminderStmt.run(req.params.id, reminderInfo.type);
      }
    }

    const updatedItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(req.params.id);

    res.json({
      message: 'Work item escalated successfully',
      workItem: updatedItem
    });
  } catch (error) {
    console.error('Error escalating work item:', error);
    res.status(500).json({ error: 'Failed to escalate work item' });
  }
});

// Get escalation history for a work item
router.get('/:id/history', (req, res) => {
  try {
    const history = db.prepare(`
      SELECT * FROM escalation_history
      WHERE work_item_id = ?
      ORDER BY timestamp DESC
    `).all(req.params.id);

    res.json(history);
  } catch (error) {
    console.error('Error fetching escalation history:', error);
    res.status(500).json({ error: 'Failed to fetch escalation history' });
  }
});

// Get all pending reminders (for dashboard)
router.get('/reminders/pending', (req, res) => {
  try {
    const reminders = db.prepare(`
      SELECT r.*, w.title, w.dependency_poc, w.current_stage
      FROM reminders r
      JOIN work_items w ON r.work_item_id = w.id
      WHERE r.sent = 0 AND w.current_stage != 'resolved'
      ORDER BY r.scheduled_for ASC
    `).all();

    res.json(reminders);
  } catch (error) {
    console.error('Error fetching reminders:', error);
    res.status(500).json({ error: 'Failed to fetch reminders' });
  }
});

module.exports = router;
