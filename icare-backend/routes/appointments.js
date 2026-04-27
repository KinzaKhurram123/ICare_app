const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const Appointment = require('../models/Appointment');
const DoctorProfile = require('../models/DoctorProfile');
const { authMiddleware } = require('../middleware/auth');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

async function getAppointments(userId, userRole) {
  await connectMongoDB();
  const uid = toId(userId);
  let appointments;

  if (userRole === 'doctor') {
    appointments = await Appointment.find({ doctor_id: uid }).lean();
    const patientIds = [...new Set(appointments.map(a => a.patient_id.toString()))];
    const patients = await User.find({ _id: { $in: patientIds.map(id => toId(id)) } }).lean();
    const pMap = {};
    patients.forEach(p => { pMap[p._id.toString()] = p; });
    return appointments.map(a => ({
      ...a,
      id: a._id.toString(),
      _id: a._id.toString(),
      patient_id: a.patient_id.toString(),
      patient_name: pMap[a.patient_id.toString()]?.username || pMap[a.patient_id.toString()]?.name,
      patient_email: pMap[a.patient_id.toString()]?.email,
      patient_phone: pMap[a.patient_id.toString()]?.phone,
    }));
  } else {
    appointments = await Appointment.find({ patient_id: uid }).lean();
    const doctorIds = [...new Set(appointments.map(a => a.doctor_id.toString()))];
    const doctors = await User.find({ _id: { $in: doctorIds.map(id => toId(id)) } }).lean();
    const profiles = await DoctorProfile.find({ user_id: { $in: doctorIds.map(id => toId(id)) } }).lean();
    const dMap = {};
    doctors.forEach(d => { dMap[d._id.toString()] = d; });
    const pMap = {};
    profiles.forEach(p => { pMap[p.user_id.toString()] = p; });
    return appointments.map(a => ({
      ...a,
      id: a._id.toString(),
      _id: a._id.toString(),
      doctor_id: a.doctor_id.toString(),
      doctor_name: dMap[a.doctor_id.toString()]?.username || dMap[a.doctor_id.toString()]?.name,
      doctor_email: dMap[a.doctor_id.toString()]?.email,
      doctor_phone: dMap[a.doctor_id.toString()]?.phone,
      specialization: pMap[a.doctor_id.toString()]?.specialization,
      consultation_fee: pMap[a.doctor_id.toString()]?.consultation_fee,
    }));
  }
}

// GET /appointments
router.get('/', authMiddleware, async (req, res) => {
  try {
    const appts = await getAppointments(req.user.id, req.user.role);
    res.json({ success: true, appointments: appts });
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch appointments' });
  }
});

// GET /appointments/getAppointments
router.get('/getAppointments', authMiddleware, async (req, res) => {
  try {
    const appts = await getAppointments(req.user.id, req.user.role);
    res.json({ success: true, appointments: appts, count: appts.length });
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch appointments' });
  }
});

// POST /appointments - create
router.post('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const patientId = toId(req.user.id);
    const { doctorId, appointmentDate, appointmentTime, consultationType, notes } = req.body;

    if (!doctorId || !appointmentDate || !appointmentTime) {
      return res.status(400).json({ success: false, message: 'Doctor, date, and time are required' });
    }

    const doctor = await User.findOne({ _id: toId(doctorId), role: /^doctor$/i });
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }

    const appt = await Appointment.create({
      patient_id: patientId,
      doctor_id: toId(doctorId),
      appointment_date: appointmentDate,
      appointment_time: appointmentTime,
      consultation_type: consultationType || 'in-person',
      notes: notes || '',
      status: 'pending',
    });

    res.status(201).json({ success: true, message: 'Appointment booked successfully', appointment: { ...appt.toObject(), id: appt._id.toString() } });
  } catch (error) {
    console.error('Create appointment error:', error);
    res.status(500).json({ success: false, message: 'Failed to book appointment' });
  }
});

// POST /appointments/book_appointment
router.post('/book_appointment', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const patientId = toId(req.user.id);
    const { doctorId, date, timeSlot, reason } = req.body;

    if (!doctorId || !date || !timeSlot) {
      return res.status(400).json({ success: false, message: 'Doctor, date, and time are required' });
    }

    const doctor = await User.findOne({ _id: toId(doctorId), role: /^doctor$/i });
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }

    const appt = await Appointment.create({
      patient_id: patientId,
      doctor_id: toId(doctorId),
      appointment_date: new Date(date).toISOString().split('T')[0],
      appointment_time: timeSlot,
      consultation_type: 'in-person',
      notes: reason || '',
      status: 'pending',
    });

    res.status(201).json({ success: true, message: 'Appointment booked successfully', appointment: { ...appt.toObject(), id: appt._id.toString() } });
  } catch (error) {
    console.error('Book appointment error:', error);
    res.status(500).json({ success: false, message: 'Failed to book appointment' });
  }
});

// PUT /appointments/update_status
router.put('/update_status', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { appointmentId, status } = req.body;
    const userId = toId(req.user.id);

    const validStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const appt = await Appointment.findOne({
      _id: toId(appointmentId),
      $or: [{ patient_id: userId }, { doctor_id: userId }],
    });

    if (!appt) return res.status(404).json({ success: false, message: 'Appointment not found or access denied' });

    appt.status = status;
    await appt.save();

    res.json({ success: true, message: 'Status updated successfully', appointment: { ...appt.toObject(), id: appt._id.toString() } });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ success: false, message: 'Failed to update status' });
  }
});

// PUT /appointments/:id
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { status } = req.body;

    const validStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const appt = await Appointment.findOne({
      _id: toId(req.params.id),
      $or: [{ patient_id: userId }, { doctor_id: userId }],
    });

    if (!appt) return res.status(404).json({ success: false, message: 'Appointment not found or access denied' });

    appt.status = status;
    await appt.save();

    res.json({ success: true, message: 'Appointment updated successfully', appointment: { ...appt.toObject(), id: appt._id.toString() } });
  } catch (error) {
    console.error('Update appointment error:', error);
    res.status(500).json({ success: false, message: 'Failed to update appointment' });
  }
});

// DELETE /appointments/:id
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);

    const appt = await Appointment.findOne({
      _id: toId(req.params.id),
      $or: [{ patient_id: userId }, { doctor_id: userId }],
    });

    if (!appt) return res.status(404).json({ success: false, message: 'Appointment not found or access denied' });

    await appt.deleteOne();
    res.json({ success: true, message: 'Appointment deleted successfully' });
  } catch (error) {
    console.error('Delete appointment error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete appointment' });
  }
});

module.exports = router;
