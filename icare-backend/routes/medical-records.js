const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { authMiddleware } = require('../middleware/auth');
const MedicalRecord = require('../models/MedicalRecord');

// POST /api/medical-records/create
router.post('/create', authMiddleware, async (req, res) => {
  try {
    const {
      patientId,
      appointmentId,
      diagnosis,
      symptoms,
      prescription,
      labTests,
      vitalSigns,
      notes,
      followUpDate,
      followUpDays,
      followUpMonths,
      referredLaboratory,
      selectedPharmacy,
      assignedCourses,
    } = req.body;

    if (!patientId || !diagnosis) {
      return res.status(400).json({ success: false, message: 'patientId and diagnosis are required' });
    }

    const record = await MedicalRecord.create({
      doctor: req.user.id || req.user._id,
      patient: patientId,
      appointment: appointmentId || undefined,
      diagnosis,
      symptoms: symptoms || [],
      prescription: prescription || {},
      labTests: labTests || [],
      vitalSigns: vitalSigns || {},
      notes: notes || '',
      followUpDate: followUpDate ? new Date(followUpDate) : undefined,
      followUpDays: followUpDays || 0,
      followUpMonths: followUpMonths || 0,
      referredLaboratory: referredLaboratory && mongoose.isValidObjectId(referredLaboratory) ? referredLaboratory : undefined,
      selectedPharmacy: selectedPharmacy && mongoose.isValidObjectId(selectedPharmacy) ? selectedPharmacy : undefined,
      assignedCourses: assignedCourses || [],
    });

    const populated = await MedicalRecord.findById(record._id)
      .populate('doctor', 'name email')
      .populate('patient', 'name email');

    res.status(201).json({ success: true, record: populated });
  } catch (err) {
    console.error('Create medical record error:', err);
    res.status(500).json({ success: false, message: 'Internal server error', error: err.message });
  }
});

// GET /api/medical-records/patient/:patientId
router.get('/patient/:patientId', authMiddleware, async (req, res) => {
  try {
    const records = await MedicalRecord.find({ patient: req.params.patientId })
      .populate('doctor', 'name email')
      .populate('patient', 'name email')
      .sort({ createdAt: -1 });

    res.json({ success: true, records, count: records.length });
  } catch (err) {
    console.error('Get patient records error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// GET /api/medical-records/doctor
router.get('/doctor', authMiddleware, async (req, res) => {
  try {
    const records = await MedicalRecord.find({ doctor: req.user.id || req.user._id })
      .populate('doctor', 'name email')
      .populate('patient', 'name email')
      .sort({ createdAt: -1 });

    res.json({ success: true, records, count: records.length });
  } catch (err) {
    console.error('Get doctor records error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// GET /api/medical-records/my-records
router.get('/my-records', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const role = req.user.role?.toLowerCase();

    const query = role === 'doctor' ? { doctor: userId } : { patient: userId };

    const records = await MedicalRecord.find(query)
      .populate('doctor', 'name email')
      .populate('patient', 'name email')
      .sort({ createdAt: -1 });

    res.json({ success: true, records, count: records.length });
  } catch (err) {
    console.error('Get my records error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// GET /api/medical-records/:id
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const record = await MedicalRecord.findById(req.params.id)
      .populate('doctor', 'name email')
      .populate('patient', 'name email');

    if (!record) return res.status(404).json({ success: false, message: 'Record not found' });

    res.json({ success: true, record });
  } catch (err) {
    console.error('Get record error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// PUT /api/medical-records/:id
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const record = await MedicalRecord.findByIdAndUpdate(req.params.id, req.body, { new: true })
      .populate('doctor', 'name email')
      .populate('patient', 'name email');

    if (!record) return res.status(404).json({ success: false, message: 'Record not found' });

    res.json({ success: true, record });
  } catch (err) {
    console.error('Update record error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

module.exports = router;
