const express = require('express');
const router = express.Router();
const { connectMongoDB } = require('../config/mongodb');

// Health check / DB status
router.get('/status', async (req, res) => {
  try {
    await connectMongoDB();
    res.json({ success: true, message: 'MongoDB connected', database: 'MongoDB' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Database connection failed', error: error.message });
  }
});

router.post('/init', async (req, res) => {
  res.json({ success: true, message: 'MongoDB does not require table initialization. Collections are created automatically.' });
});

router.all('/{*path}', (req, res) => {
  res.json({ success: true, message: 'Database API (MongoDB)' });
});

module.exports = router;
