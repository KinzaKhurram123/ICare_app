const express = require('express');
const router = express.Router();

// Stub: seed not needed for MongoDB
router.all('/{*path}', (req, res) => {
  res.json({ success: true, message: 'Seed route (not needed for MongoDB)' });
});

router.all('/', (req, res) => {
  res.json({ success: true, message: 'Seed route (not needed for MongoDB)' });
});

module.exports = router;
