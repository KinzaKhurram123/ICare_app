const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

// Admin-only middleware
function adminOnly(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
}

// ─── ENSURE ADMIN EXISTS (called on startup) ──────────────────────────────────
async function ensureAdminExists() {
  try {
    await connectMongoDB();
    const existing = await User.findOne({ email: 'admin@icare.com' });
    if (!existing) {
      const hashed = await bcrypt.hash('adminPassword123', 10);
      await User.create({
        username: 'Admin',
        name: 'Admin',
        email: 'admin@icare.com',
        password: hashed,
        role: 'admin',
        is_approved: true,
        is_active: true,
      });
      console.log('✅ Admin user created: admin@icare.com');
    } else if (existing.role !== 'admin') {
      await User.findByIdAndUpdate(existing._id, { $set: { role: 'admin', is_active: true, is_approved: true } });
      console.log('✅ Existing user promoted to admin: admin@icare.com');
    }
  } catch (err) {
    console.error('⚠️  ensureAdminExists error:', err.message);
  }
}

// Run on module load
ensureAdminExists();

// ─── PENDING USERS ────────────────────────────────────────────────────────────
// GET /api/admin/pending-users
router.get('/pending-users', authMiddleware, adminOnly, async (req, res) => {
  try {
    await connectMongoDB();
    const users = await User.find({
      is_approved: false,
      role: { $nin: ['admin', 'patient'] },
    }).select('-password').lean();

    const result = users.map(u => ({
      _id: u._id.toString(),
      name: u.name || u.username || '',
      email: u.email || '',
      role: u.role || '',
      phone: u.phone || '',
      createdAt: u.createdAt,
    }));

    res.json({ success: true, users: result, count: result.length });
  } catch (err) {
    console.error('pending-users error:', err);
    res.json({ success: true, users: [], count: 0 });
  }
});

// ─── APPROVED USERS ───────────────────────────────────────────────────────────
// GET /api/admin/approved-users?role=Doctor
router.get('/approved-users', authMiddleware, adminOnly, async (req, res) => {
  try {
    await connectMongoDB();
    const { role } = req.query;

    const query = { is_approved: { $ne: false }, is_active: { $ne: false } };
    if (role) {
      // Case-insensitive role match
      query.role = { $regex: new RegExp(`^${role}$`, 'i') };
    }

    const users = await User.find(query).select('-password').lean();
    const result = users.map(u => ({
      _id: u._id.toString(),
      name: u.name || u.username || '',
      email: u.email || '',
      role: u.role || '',
      phone: u.phone || '',
      createdAt: u.createdAt,
      isApproved: true,
    }));

    res.json({ success: true, users: result, count: result.length });
  } catch (err) {
    console.error('approved-users error:', err);
    res.json({ success: true, users: [], count: 0 });
  }
});

// ─── ALL USERS ────────────────────────────────────────────────────────────────
router.get('/users', authMiddleware, adminOnly, async (req, res) => {
  try {
    await connectMongoDB();
    const { role, status } = req.query;
    const query = {};
    if (role) query.role = { $regex: new RegExp(`^${role}$`, 'i') };
    if (status === 'pending') query.is_approved = false;
    if (status === 'approved') query.is_approved = { $ne: false };

    const users = await User.find(query).select('-password').lean();
    const result = users.map(u => ({
      _id: u._id.toString(),
      name: u.name || u.username || '',
      email: u.email || '',
      role: u.role || '',
      phone: u.phone || '',
      createdAt: u.createdAt,
      isApproved: u.is_approved !== false,
      isActive: u.is_active !== false,
    }));

    res.json({ success: true, users: result, count: result.length });
  } catch (err) {
    console.error('admin users error:', err);
    res.json({ success: true, users: [], count: 0 });
  }
});

// ─── APPROVE USER ─────────────────────────────────────────────────────────────
router.put('/approve/:userId', authMiddleware, adminOnly, async (req, res) => {
  try {
    await connectMongoDB();
    const user = await User.findByIdAndUpdate(
      toId(req.params.userId),
      { $set: { is_approved: true, is_active: true } },
      { new: true }
    ).select('-password').lean();

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User approved', user: { _id: user._id.toString(), email: user.email, role: user.role } });
  } catch (err) {
    console.error('approve user error:', err);
    res.status(500).json({ success: false, message: 'Failed to approve user' });
  }
});

// ─── REJECT / DEACTIVATE USER ─────────────────────────────────────────────────
router.put('/reject/:userId', authMiddleware, adminOnly, async (req, res) => {
  try {
    await connectMongoDB();
    const user = await User.findByIdAndUpdate(
      toId(req.params.userId),
      { $set: { is_approved: false, is_active: false } },
      { new: true }
    ).select('-password').lean();

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User rejected/deactivated' });
  } catch (err) {
    console.error('reject user error:', err);
    res.status(500).json({ success: false, message: 'Failed to reject user' });
  }
});

// ─── STATS ────────────────────────────────────────────────────────────────────
router.get('/stats', authMiddleware, adminOnly, async (req, res) => {
  try {
    await connectMongoDB();
    const [total, patients, doctors, labs, pharmacies, pending] = await Promise.all([
      User.countDocuments({ is_active: { $ne: false } }),
      User.countDocuments({ role: { $regex: /^patient$/i }, is_active: { $ne: false } }),
      User.countDocuments({ role: { $regex: /^doctor$/i }, is_active: { $ne: false } }),
      User.countDocuments({ role: { $regex: /^lab$/i }, is_active: { $ne: false } }),
      User.countDocuments({ role: { $regex: /^pharmacy$/i }, is_active: { $ne: false } }),
      User.countDocuments({ is_approved: false }),
    ]);
    res.json({ success: true, stats: { total, patients, doctors, labs, pharmacies, pending } });
  } catch (err) {
    res.json({ success: true, stats: { total: 0, patients: 0, doctors: 0, labs: 0, pharmacies: 0, pending: 0 } });
  }
});

// ─── FALLBACK — catch any other /api/admin/* calls ───────────────────────────
router.all('/{*path}', (req, res) => {
  res.json({ success: true, users: [], data: [], count: 0 });
});

module.exports = router;
