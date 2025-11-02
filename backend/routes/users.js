const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { v4: uuidv4 } = require('uuid');

// Generate unique username
function generateUsername(displayName) {
  const base = displayName.toLowerCase().replace(/[^a-z0-9]/g, '');
  const uniqueId = uuidv4().split('-')[0];
  return `${base}_${uniqueId}`;
}

// Create new user (onboarding)
router.post('/onboard', (req, res) => {
  try {
    const { displayName, role } = req.body;

    if (!displayName || displayName.trim() === '') {
      return res.status(400).json({ error: 'Display name is required' });
    }

    const username = generateUsername(displayName);

    const stmt = db.prepare(`
      INSERT INTO users (username, display_name, role)
      VALUES (?, ?, ?)
    `);

    const result = stmt.run(username, displayName.trim(), role || 'senior');

    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(result.lastInsertRowid);

    res.status(201).json({
      message: 'User created successfully',
      user
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

// Get user by ID
router.get('/:id', (req, res) => {
  try {
    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// Get all users
router.get('/', (req, res) => {
  try {
    const users = db.prepare('SELECT * FROM users ORDER BY created_at DESC').all();
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Update FCM token for push notifications
router.put('/:id/fcm-token', (req, res) => {
  try {
    const { fcmToken } = req.body;

    const stmt = db.prepare('UPDATE users SET fcm_token = ? WHERE id = ?');
    stmt.run(fcmToken, req.params.id);

    res.json({ message: 'FCM token updated successfully' });
  } catch (error) {
    console.error('Error updating FCM token:', error);
    res.status(500).json({ error: 'Failed to update FCM token' });
  }
});

module.exports = router;
