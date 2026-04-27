const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const { authMiddleware } = require('../middleware/auth');
const MedicalRecord = require('../models/MedicalRecord');
const PharmacyOrder = require('../models/PharmacyOrder');
const LabTestRequest = require('../models/LabTestRequest');

// POST /api/medical-records/create
router.post('/create', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
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

    // Extract and normalize lab tests
    const normalizedLabTests = (() => {
      const raw = prescription?.labTests || labTests || [];
      return raw.map(t => typeof t === 'string' ? { name: t, urgency: 'Routine' } : t);
    })();

    // Extract test names for top-level labTests field (backward compatibility)
    const labTestNames = normalizedLabTests.map(t => t.name || t);

    const record = await MedicalRecord.create({
      doctor: req.user.id || req.user._id,
      patient: patientId,
      appointment: appointmentId || undefined,
      diagnosis,
      symptoms: symptoms || [],
      prescription: {
        ...(prescription || {}),
        labTests: normalizedLabTests,
      },
      labTests: labTestNames,
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

    // ── AUTO-TRIGGER: Send prescription to pharmacy ──────────────────────────
    if (
      selectedPharmacy &&
      mongoose.isValidObjectId(selectedPharmacy) &&
      prescription?.medicines?.length > 0
    ) {
      try {
        const orderItems = prescription.medicines.map((m) => ({
          product_name: m.name || 'Medicine',
          generic_name: m.dosage || '',
          quantity: 1,
          price: 0,
        }));
        const rxOrderNumber = `RX-${Date.now().toString().slice(-8)}-${Math.random().toString(36).slice(-4).toUpperCase()}`;
        await PharmacyOrder.create({
          patient_id: patientId,
          pharmacy_id: selectedPharmacy,
          prescription_id: record._id.toString(),
          delivery_address: '',
          total_amount: 0,
          status: 'pending',
          order_number: rxOrderNumber,
          orderNumber: rxOrderNumber,
          items: orderItems,
        });
        console.log(`✅ Pharmacy order auto-created for record ${record._id}`);
      } catch (pharmErr) {
        console.error('⚠️  Auto pharmacy order failed:', pharmErr.message);
      }
    }

    // ── AUTO-TRIGGER: Send lab tests to laboratory ───────────────────────────
    if (
      referredLaboratory &&
      mongoose.isValidObjectId(referredLaboratory) &&
      labTests?.length > 0
    ) {
      try {
        const labBookings = labTests.map((testName) =>
          LabTestRequest.create({
            patient_id: patientId,
            lab_id: referredLaboratory,
            test_type: testName,
            status: 'pending',
            medical_record_id: record._id.toString(),
          })
        );
        await Promise.all(labBookings);
        console.log(`✅ ${labTests.length} lab test(s) auto-created for record ${record._id}`);
      } catch (labErr) {
        console.error('⚠️  Auto lab booking failed:', labErr.message);
      }
    }

    res.status(201).json({ success: true, record: populated });
  } catch (err) {
    console.error('Create medical record error:', err);
    res.status(500).json({ success: false, message: 'Internal server error', error: err.message });
  }
});

// GET /api/medical-records/patient/:patientId
router.get('/patient/:patientId', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
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
    await connectMongoDB();
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
    await connectMongoDB();
    const userId = req.user.id || req.user._id;
    const role = req.user.role?.toLowerCase();

    const query = role === 'doctor' ? { doctor: userId } : { patient: userId };

    const records = await MedicalRecord.find(query)
      .populate('doctor', 'name email')
      .populate('patient', 'name email')
      .sort({ createdAt: -1 })
      .lean();

    // Normalize records so prescription.labTests is always an accessible array
    const normalized = records.map(r => ({
      ...r,
      _id: r._id.toString(),
      prescription: {
        ...(r.prescription || {}),
        medicines: r.prescription?.medicines || [],
        labTests: r.prescription?.labTests || [],
      },
      labTests: r.labTests || [],
      doctor: r.doctor ? { ...r.doctor, _id: r.doctor._id?.toString() } : null,
      patient: r.patient ? { ...r.patient, _id: r.patient._id?.toString() } : null,
    }));

    res.json({ success: true, records: normalized, count: normalized.length });
  } catch (err) {
    console.error('Get my records error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// GET /api/medical-records/:id
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
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
    await connectMongoDB();
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
