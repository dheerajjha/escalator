const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Add standup update for a work item
router.post('/', (req, res) => {
  try {
    const { workItemId, updateText, date } = req.body;

    if (!workItemId || !updateText) {
      return res.status(400).json({
        error: 'Work item ID and update text are required'
      });
    }

    const stmt = db.prepare(`
      INSERT INTO standup_updates (work_item_id, update_text, date)
      VALUES (?, ?, ?)
    `);

    const result = stmt.run(
      workItemId,
      updateText,
      date || new Date().toISOString().split('T')[0]
    );

    const standupUpdate = db.prepare('SELECT * FROM standup_updates WHERE id = ?').get(result.lastInsertRowid);

    res.status(201).json({
      message: 'Standup update added successfully',
      standupUpdate
    });
  } catch (error) {
    console.error('Error adding standup update:', error);
    res.status(500).json({ error: 'Failed to add standup update' });
  }
});

// Get standup updates for a work item
router.get('/work-item/:workItemId', (req, res) => {
  try {
    const updates = db.prepare(`
      SELECT * FROM standup_updates
      WHERE work_item_id = ?
      ORDER BY date DESC, created_at DESC
    `).all(req.params.workItemId);

    res.json(updates);
  } catch (error) {
    console.error('Error fetching standup updates:', error);
    res.status(500).json({ error: 'Failed to fetch standup updates' });
  }
});

// Get all standup updates for a user (across all work items)
router.get('/user/:userId', (req, res) => {
  try {
    const updates = db.prepare(`
      SELECT s.*, w.title as work_item_title
      FROM standup_updates s
      JOIN work_items w ON s.work_item_id = w.id
      WHERE w.user_id = ?
      ORDER BY s.date DESC, s.created_at DESC
    `).all(req.params.userId);

    res.json(updates);
  } catch (error) {
    console.error('Error fetching user standup updates:', error);
    res.status(500).json({ error: 'Failed to fetch standup updates' });
  }
});

// Get standup updates by date
router.get('/date/:date', (req, res) => {
  try {
    const { userId } = req.query;

    let query = `
      SELECT s.*, w.title as work_item_title, w.user_id
      FROM standup_updates s
      JOIN work_items w ON s.work_item_id = w.id
      WHERE s.date = ?
    `;

    const params = [req.params.date];

    if (userId) {
      query += ' AND w.user_id = ?';
      params.push(userId);
    }

    query += ' ORDER BY s.created_at DESC';

    const updates = db.prepare(query).all(...params);

    res.json(updates);
  } catch (error) {
    console.error('Error fetching standup updates by date:', error);
    res.status(500).json({ error: 'Failed to fetch standup updates' });
  }
});

// Delete standup update
router.delete('/:id', (req, res) => {
  try {
    const stmt = db.prepare('DELETE FROM standup_updates WHERE id = ?');
    stmt.run(req.params.id);

    res.json({ message: 'Standup update deleted successfully' });
  } catch (error) {
    console.error('Error deleting standup update:', error);
    res.status(500).json({ error: 'Failed to delete standup update' });
  }
});

module.exports = router;
