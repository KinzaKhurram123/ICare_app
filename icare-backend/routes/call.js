const express = require('express');
const router = express.Router();
const { connectMongoDB } = require('../config/mongodb');
const CallSignal = require('../models/CallSignal');
const { authMiddleware } = require('../middleware/auth');

// POST /api/call/initiate — caller sends when starting a call
router.post('/initiate', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { receiverId, channelName, callType = 'video', callerName } = req.body;
    if (!receiverId || !channelName) {
      return res.status(400).json({ success: false, message: 'receiverId and channelName required' });
    }
    // Cancel any existing pending signal between these two users
    await CallSignal.deleteMany({
      $or: [
        { callerId: req.user.id, receiverId },
        { callerId: receiverId, receiverId: req.user.id },
      ],
      status: 'pending',
    });
    const signal = await CallSignal.create({
      channelName,
      callerId: req.user.id,
      callerName: callerName || 'Unknown',
      receiverId,
      callType,
    });
    res.json({ success: true, signalId: signal._id });
  } catch (err) {
    console.error('Call initiate error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/call/incoming — callee polls this to check for incoming calls
router.get('/incoming', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const signal = await CallSignal.findOne({
      receiverId: req.user.id,
      status: 'pending',
    }).sort({ createdAt: -1 });
    if (!signal) {
      return res.json({ success: true, hasIncomingCall: false });
    }
    res.json({
      success: true,
      hasIncomingCall: true,
      signal: {
        id: signal._id,
        channelName: signal.channelName,
        callerName: signal.callerName,
        callerId: signal.callerId,
        callType: signal.callType,
      },
    });
  } catch (err) {
    console.error('Call incoming error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/call/respond — callee accepts or rejects
router.post('/respond', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { signalId, action } = req.body; // action: 'accepted' | 'rejected'
    if (!signalId || !action) {
      return res.status(400).json({ success: false, message: 'signalId and action required' });
    }
    await CallSignal.findByIdAndUpdate(signalId, { status: action });
    res.json({ success: true });
  } catch (err) {
    console.error('Call respond error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/call/end — either party ends the call
router.post('/end', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { channelName } = req.body;
    if (channelName) {
      await CallSignal.updateMany(
        { channelName, status: { $in: ['pending', 'accepted'] } },
        { status: 'ended' },
      );
    }
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
