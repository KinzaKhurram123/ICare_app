const express = require('express');
const router = express.Router();
const { connectMongoDB } = require('../config/mongodb');
const { authMiddleware } = require('../middleware/auth');

// GET /api/notifications — get notifications for current user
router.get('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Notification = require('../models/Notification');
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(100)
      .lean();
    res.json({ success: true, notifications });
  } catch (err) {
    console.error('GET /notifications error:', err);
    res.json({ success: true, notifications: [] });
  }
});

// PUT /api/notifications/:id/read — mark one as read
router.put('/:id/read', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Notification = require('../models/Notification');
    await Notification.findByIdAndUpdate(req.params.id, { read: true });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to mark as read' });
  }
});

// PUT /api/notifications/read-all — mark all as read
router.put('/read-all', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Notification = require('../models/Notification');
    await Notification.updateMany({ userId: req.user.id, read: false }, { read: true });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to mark all as read' });
  }
});

// POST /api/notifications — create a notification (internal use)
router.post('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Notification = require('../models/Notification');
    const { userId, type, title, message } = req.body;
    const notif = await Notification.create({
      userId: userId || req.user.id,
      type: type || 'general',
      title: title || 'Notification',
      message: message || '',
      read: false,
    });
    res.status(201).json({ success: true, notification: notif });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to create notification' });
  }
});

module.exports = router;