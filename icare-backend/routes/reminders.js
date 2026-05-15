const express = require('express');
const router = express.Router();
const { connectMongoDB } = require('../config/mongodb');
const { authMiddleware } = require('../middleware/auth');

// GET /api/reminders — get reminders for current user
router.get('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Reminder = require('../models/Reminder');
    const reminders = await Reminder.find({ userId: req.user.id })
      .sort({ scheduledFor: -1 })
      .limit(100)
      .lean();
    res.json({ success: true, reminders });
  } catch (err) {
    console.error('GET /reminders error:', err);
    res.json({ success: true, reminders: [] });
  }
});

// POST /api/reminders — create a reminder
router.post('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Reminder = require('../models/Reminder');
    const { title, message, type, scheduledFor, remindBeforeMinutes, recurrence, prescriptionId, consultationId } = req.body;
    if (!title || title.trim() === '') {
      return res.status(400).json({ success: false, message: 'Title is required' });
    }
    const reminder = await Reminder.create({
      userId: req.user.id,
      title: title.trim(),
      message: message || '',
      type: type || 'self_created',
      scheduledFor: scheduledFor || null,
      remindBeforeMinutes: remindBeforeMinutes || 15,
      recurrence: recurrence || 'none',
      prescriptionId: prescriptionId || null,
      consultationId: consultationId || null,
    });
    res.status(201).json({ success: true, reminder: reminder.toObject() });
  } catch (err) {
    console.error('POST /reminders error:', err);
    res.status(500).json({ success: false, message: 'Failed to create reminder' });
  }
});

// PUT /api/reminders/:id — update a reminder
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Reminder = require('../models/Reminder');
    const reminder = await Reminder.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { $set: req.body },
      { new: true }
    );
    if (!reminder) return res.status(404).json({ success: false, message: 'Reminder not found' });
    res.json({ success: true, reminder });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update reminder' });
  }
});

// DELETE /api/reminders/:id — delete a reminder
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Reminder = require('../models/Reminder');
    const reminder = await Reminder.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
    if (!reminder) return res.status(404).json({ success: false, message: 'Reminder not found' });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to delete reminder' });
  }
});

// PUT /api/reminders/:id/complete — mark reminder as completed
router.put('/:id/complete', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const Reminder = require('../models/Reminder');
    const reminder = await Reminder.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { isCompleted: true },
      { new: true }
    );
    if (!reminder) return res.status(404).json({ success: false, message: 'Reminder not found' });
    res.json({ success: true, reminder });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to complete reminder' });
  }
});

module.exports = router;