const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const { authMiddleware } = require('../middleware/auth');
const User = require('../models/User');
const InstructorProfile = require('../models/InstructorProfile');
const Course = require('../models/Course');
const Precaution = require('../models/Precaution');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

// ── STATS ────────────────────────────────────────────────────────────────────
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const instructorId = toId(req.user.id);
    const [totalCourses, totalPrecautions, courseList] = await Promise.all([
      Course.countDocuments({ instructor_id: instructorId, is_active: true }),
      Precaution.countDocuments({ instructor_id: instructorId, is_active: true }),
      Course.find({ instructor_id: instructorId }).select('assigned_to rating').lean(),
    ]);
    const totalStudents = new Set(courseList.flatMap(c => c.assigned_to.map(String))).size;
    const ratings = courseList.filter(c => c.rating > 0).map(c => c.rating);
    const avgRating = ratings.length ? (ratings.reduce((a, b) => a + b, 0) / ratings.length).toFixed(1) : 0;
    res.json({ success: true, stats: { totalCourses, totalStudents, avgRating: parseFloat(avgRating), totalPrecautions } });
  } catch (e) {
    console.error('Stats error:', e);
    res.status(500).json({ success: false, message: 'Failed to get stats' });
  }
});

// ── PROFILE ──────────────────────────────────────────────────────────────────
router.get('/me', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const user = await User.findById(userId).lean();
    let profile = await InstructorProfile.findOne({ user_id: userId }).lean();
    if (!profile) profile = await InstructorProfile.create({ user_id: userId });
    res.json({ success: true, instructor: { _id: profile._id.toString(), user_id: userId.toString(), name: user?.username || user?.name || '', email: user?.email || '', ...profile } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.post('/add_instructor_details', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const update = {};
    const fields = ['bio', 'specialization', 'experience_years', 'profile_image'];
    fields.forEach(f => { if (req.body[f] !== undefined) update[f] = req.body[f]; });
    const profile = await InstructorProfile.findOneAndUpdate({ user_id: userId }, { $set: update }, { new: true, upsert: true });
    res.json({ success: true, instructor: profile });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.get('/get_all_instructors', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const instructors = await InstructorProfile.find().lean();
    const userIds = instructors.map(i => i.user_id);
    const users = await User.find({ _id: { $in: userIds } }).lean();
    const userMap = {};
    users.forEach(u => { userMap[u._id.toString()] = u; });
    const result = instructors.map(p => {
      const u = userMap[p.user_id.toString()] || {};
      return { _id: p._id.toString(), user_id: p.user_id.toString(), name: u.username || u.name || '', email: u.email || '', ...p };
    });
    res.json({ success: true, instructors: result });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.get('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const id = toId(req.params.id);
    if (!id) return res.status(400).json({ success: false, message: 'Invalid ID' });
    const profile = await InstructorProfile.findById(id).lean();
    if (!profile) return res.status(404).json({ success: false, message: 'Not found' });
    const user = await User.findById(profile.user_id).lean() || {};
    res.json({ success: true, instructor: { _id: profile._id.toString(), name: user.username || user.name || '', email: user.email || '', ...profile } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── COURSES ──────────────────────────────────────────────────────────────────
router.get('/courses', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const filter = { is_active: true };
    if (req.query.instructorId) filter.instructor_id = toId(req.query.instructorId);
    if (req.query.q) filter.title = { $regex: req.query.q, $options: 'i' };
    if (req.query.visibility) filter.visibility = req.query.visibility;
    const courses = await Course.find(filter).lean();
    res.json({ success: true, courses, count: courses.length });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.post('/courses', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const course = await Course.create({ ...req.body, instructor_id: toId(req.user.id) });
    res.status(201).json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.post('/courses/assign', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { courseId, targetUserId } = req.body;
    const course = await Course.findByIdAndUpdate(
      toId(courseId),
      { $addToSet: { assigned_to: toId(targetUserId) } },
      { new: true }
    );
    if (!course) return res.status(404).json({ success: false, message: 'Course not found' });
    res.json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.get('/courses/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const course = await Course.findById(toId(req.params.id)).lean();
    if (!course) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.put('/courses/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const course = await Course.findByIdAndUpdate(toId(req.params.id), { $set: req.body }, { new: true });
    if (!course) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.delete('/courses/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    await Course.findByIdAndUpdate(toId(req.params.id), { is_active: false });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── PRECAUTIONS ───────────────────────────────────────────────────────────────
router.get('/precautions', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const filter = { is_active: true };
    if (req.query.instructorId) filter.instructor_id = toId(req.query.instructorId);
    const precautions = await Precaution.find(filter).lean();
    res.json({ success: true, precautions, count: precautions.length });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.post('/precautions', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const p = await Precaution.create({ ...req.body, instructor_id: toId(req.user.id) });
    res.status(201).json({ success: true, precaution: p });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.get('/precautions/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const p = await Precaution.findById(toId(req.params.id)).lean();
    if (!p) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, precaution: p });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.put('/precautions/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const p = await Precaution.findByIdAndUpdate(toId(req.params.id), { $set: req.body }, { new: true });
    if (!p) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, precaution: p });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.delete('/precautions/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    await Precaution.findByIdAndUpdate(toId(req.params.id), { is_active: false });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── ASSIGNED LEARNERS ─────────────────────────────────────────────────────────
router.get('/assigned-learners', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const instructorId = toId(req.user.id);
    const courses = await Course.find({ instructor_id: instructorId, is_active: true }).select('title assigned_to').lean();
    const allUserIds = [...new Set(courses.flatMap(c => c.assigned_to.map(String)))];
    const users = await User.find({ _id: { $in: allUserIds.map(toId) } }).select('username name email role').lean();
    const learners = users.map(u => ({
      _id: u._id.toString(),
      name: u.username || u.name,
      email: u.email,
      role: u.role,
      enrolledCourses: courses.filter(c => c.assigned_to.map(String).includes(u._id.toString())).map(c => ({ _id: c._id.toString(), title: c.title })),
    }));
    res.json({ success: true, learners, count: learners.length });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;
