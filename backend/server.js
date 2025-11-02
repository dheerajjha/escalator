require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

// Import routes
const userRoutes = require('./routes/users');
const workItemRoutes = require('./routes/workItems');
const escalationRoutes = require('./routes/escalations');
const standupRoutes = require('./routes/standups');

// Import scheduler
const reminderScheduler = require('./services/reminderScheduler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/work-items', workItemRoutes);
app.use('/api/escalations', escalationRoutes);
app.use('/api/standups', standupRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Escalator API is running' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!', message: err.message });
});

// Start scheduler
reminderScheduler.start();

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Escalator backend running on port ${PORT}`);
  console.log(`📊 Database: ${process.env.DB_PATH || './database/escalator.db'}`);
});

module.exports = app;
