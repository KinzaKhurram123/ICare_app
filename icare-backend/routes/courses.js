const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// Stub: returns empty success
router.all('/{*path}', (req, res) => {
  res.json({ success: true, courses: [], count: 0 });
});

router.all('/', (req, res) => {
  res.json({ success: true, courses: [], count: 0 });
});

module.exports = router;
