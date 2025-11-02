const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Create new work item
router.post('/', (req, res) => {
  try {
    const {
      userId,
      title,
      description,
      dependencyPoc,
      pocEmail,
      impact,
      managerName,
      managerEmail
    } = req.body;

    if (!userId || !title || !dependencyPoc) {
      return res.status(400).json({
        error: 'User ID, title, and dependency POC are required'
      });
    }

    const stmt = db.prepare(`
      INSERT INTO work_items (
        user_id, title, description, dependency_poc, poc_email,
        impact, manager_name, manager_email, current_stage
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active')
    `);

    const result = stmt.run(
      userId, title, description, dependencyPoc, pocEmail,
      impact, managerName, managerEmail
    );

    // Create initial history entry
    const historyStmt = db.prepare(`
      INSERT INTO escalation_history (work_item_id, to_stage, action_taken, notes)
      VALUES (?, 'active', 'Created work item', ?)
    `);
    historyStmt.run(result.lastInsertRowid, description);

    // Schedule first reminder (2 days from now)
    const reminderStmt = db.prepare(`
      INSERT INTO reminders (work_item_id, reminder_type, scheduled_for)
      VALUES (?, 'nudge_day2', datetime('now', '+2 days'))
    `);
    reminderStmt.run(result.lastInsertRowid);

    const workItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(result.lastInsertRowid);

    res.status(201).json({
      message: 'Work item created successfully',
      workItem
    });
  } catch (error) {
    console.error('Error creating work item:', error);
    res.status(500).json({ error: 'Failed to create work item' });
  }
});

// Get all work items for a user
router.get('/user/:userId', (req, res) => {
  try {
    const workItems = db.prepare(`
      SELECT * FROM work_items
      WHERE user_id = ?
      ORDER BY
        CASE current_stage
          WHEN 'manager_escalation' THEN 1
          WHEN 'week1_call' THEN 2
          WHEN 'day4_second_nudge' THEN 3
          WHEN 'day2_nudge' THEN 4
          WHEN 'active' THEN 5
          WHEN 'resolved' THEN 6
        END,
        stage_updated_at DESC
    `).all(req.params.userId);

    res.json(workItems);
  } catch (error) {
    console.error('Error fetching work items:', error);
    res.status(500).json({ error: 'Failed to fetch work items' });
  }
});

// Get single work item by ID
router.get('/:id', (req, res) => {
  try {
    const workItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(req.params.id);

    if (!workItem) {
      return res.status(404).json({ error: 'Work item not found' });
    }

    // Get escalation history
    const history = db.prepare(`
      SELECT * FROM escalation_history
      WHERE work_item_id = ?
      ORDER BY timestamp DESC
    `).all(req.params.id);

    // Get standup updates
    const standups = db.prepare(`
      SELECT * FROM standup_updates
      WHERE work_item_id = ?
      ORDER BY date DESC
    `).all(req.params.id);

    res.json({
      ...workItem,
      history,
      standups
    });
  } catch (error) {
    console.error('Error fetching work item:', error);
    res.status(500).json({ error: 'Failed to fetch work item' });
  }
});

// Update work item
router.put('/:id', (req, res) => {
  try {
    const {
      title,
      description,
      dependencyPoc,
      pocEmail,
      impact,
      managerName,
      managerEmail
    } = req.body;

    const stmt = db.prepare(`
      UPDATE work_items
      SET title = ?, description = ?, dependency_poc = ?, poc_email = ?,
          impact = ?, manager_name = ?, manager_email = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);

    stmt.run(
      title, description, dependencyPoc, pocEmail,
      impact, managerName, managerEmail, req.params.id
    );

    const workItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(req.params.id);

    res.json({
      message: 'Work item updated successfully',
      workItem
    });
  } catch (error) {
    console.error('Error updating work item:', error);
    res.status(500).json({ error: 'Failed to update work item' });
  }
});

// Delete work item
router.delete('/:id', (req, res) => {
  try {
    const stmt = db.prepare('DELETE FROM work_items WHERE id = ?');
    stmt.run(req.params.id);

    res.json({ message: 'Work item deleted successfully' });
  } catch (error) {
    console.error('Error deleting work item:', error);
    res.status(500).json({ error: 'Failed to delete work item' });
  }
});

// Mark work item as resolved
router.post('/:id/resolve', (req, res) => {
  try {
    const { notes } = req.body;

    const workItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(req.params.id);

    if (!workItem) {
      return res.status(404).json({ error: 'Work item not found' });
    }

    // Update work item to resolved
    const stmt = db.prepare(`
      UPDATE work_items
      SET current_stage = 'resolved',
          stage_updated_at = CURRENT_TIMESTAMP,
          resolved_at = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);
    stmt.run(req.params.id);

    // Add history entry
    const historyStmt = db.prepare(`
      INSERT INTO escalation_history (work_item_id, from_stage, to_stage, action_taken, notes)
      VALUES (?, ?, 'resolved', 'Marked as resolved', ?)
    `);
    historyStmt.run(req.params.id, workItem.current_stage, notes);

    // Cancel pending reminders
    const reminderStmt = db.prepare(`
      DELETE FROM reminders WHERE work_item_id = ? AND sent = 0
    `);
    reminderStmt.run(req.params.id);

    const updatedItem = db.prepare('SELECT * FROM work_items WHERE id = ?').get(req.params.id);

    res.json({
      message: 'Work item resolved successfully',
      workItem: updatedItem
    });
  } catch (error) {
    console.error('Error resolving work item:', error);
    res.status(500).json({ error: 'Failed to resolve work item' });
  }
});

module.exports = router;
