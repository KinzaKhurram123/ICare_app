const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// Stub: returns empty success so Flutter doesn't crash
router.all('/{*path}', authMiddleware, (req, res) => {
  res.json({ success: true, records: [], count: 0 });
});

router.all('/', authMiddleware, (req, res) => {
  res.json({ success: true, records: [], count: 0 });
});

module.exports = router;
