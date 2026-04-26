const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const { authMiddleware } = require('../middleware/auth');
const Course = require('../models/Course');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

// GET /api/courses — list all active public courses
router.get('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const filter = { is_active: true };
    if (req.query.instructorId) filter.instructor_id = toId(req.query.instructorId);
    if (req.query.visibility) filter.visibility = req.query.visibility;
    if (req.query.q) filter.title = { $regex: req.query.q, $options: 'i' };
    const courses = await Course.find(filter).lean();
    res.json({ success: true, courses, count: courses.length });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// GET /api/courses/:id — get single course
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const course = await Course.findById(toId(req.params.id)).lean();
    if (!course) return res.status(404).json({ success: false, message: 'Course not found' });
    res.json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// POST /api/courses — create course (instructor)
router.post('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const course = await Course.create({ ...req.body, instructor_id: toId(req.user.id) });
    res.status(201).json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// PUT /api/courses/:id — update course
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const course = await Course.findByIdAndUpdate(toId(req.params.id), { $set: req.body }, { new: true });
    if (!course) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, course });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// DELETE /api/courses/:id — soft delete
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    await Course.findByIdAndUpdate(toId(req.params.id), { is_active: false });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;
