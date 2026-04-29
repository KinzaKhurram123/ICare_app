const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const DoctorProfile = require('../models/DoctorProfile');
const Appointment = require('../models/Appointment');
const { authMiddleware } = require('../middleware/auth');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

// ─── DOCTOR STATS ─────────────────────────────────────────────────────────────
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const doctorId = toId(req.user.id);
    const [total, pending, confirmed, completed, cancelled, profile] = await Promise.all([
      Appointment.countDocuments({ doctor_id: doctorId }),
      Appointment.countDocuments({ doctor_id: doctorId, status: 'pending' }),
      Appointment.countDocuments({ doctor_id: doctorId, status: 'confirmed' }),
      Appointment.countDocuments({ doctor_id: doctorId, status: 'completed' }),
      Appointment.countDocuments({ doctor_id: doctorId, status: 'cancelled' }),
      DoctorProfile.findOne({ user_id: doctorId }).lean(),
    ]);

    // Revenue = completed appointments × consultation fee
    const consultationFee = profile?.consultation_fee || 0;
    const revenue = completed * consultationFee;

    // Satisfaction = percentage of non-cancelled appointments that completed
    const attempted = total - cancelled;
    const satisfaction = attempted > 0 ? Math.round((completed / attempted) * 100) : 0;

    const avgRating = profile?.rating || 0;

    res.json({
      success: true,
      stats: {
        totalAppointments: total,
        pendingAppointments: pending,
        confirmedAppointments: confirmed,
        completedAppointments: completed,
        cancelledAppointments: cancelled,
        rating: avgRating,
        totalReviews: profile?.total_reviews || 0,
        revenue,
        satisfaction,
        avgRating,
        consultationFee,
      },
    });
  } catch (e) {
    console.error('Doctor stats error:', e);
    res.status(500).json({ success: false, message: e.message });
  }
});

// ─── GET ALL DOCTORS ──────────────────────────────────────────────────────────
router.get('/get_all_doctors', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    // Case-insensitive match — old accounts may have 'Doctor' (capital D)
    const doctors = await User.find({ role: /^doctor$/i, is_active: { $ne: false } }).lean();
    const ids = doctors.map(d => d._id);
    const profiles = await DoctorProfile.find({ user_id: { $in: ids } }).lean();
    const profileMap = {};
    profiles.forEach(p => { profileMap[p.user_id.toString()] = p; });

    const result = doctors.map(d => {
      const p = profileMap[d._id.toString()] || {};
      return {
        id: d._id.toString(),
        _id: d._id.toString(),
        name: d.username || d.name,
        email: d.email,
        phoneNumber: d.phone,
        role: d.role,
        specialization: p.specialization,
        experience: p.experience_years,
        licenseNumber: p.license_number,
        consultationFee: p.consultation_fee,
        availableDays: p.available_days,
        availableTime: p.available_hours,
        rating: p.rating || 0,
        totalReviews: p.total_reviews || 0,
      };
    });

    res.json({ success: true, doctors: result });
  } catch (error) {
    console.error('Get doctors error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch doctors' });
  }
});

// ─── UPDATE DOCTOR PROFILE ────────────────────────────────────────────────────
router.post('/add_doctor_details', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    if (req.user.role?.toLowerCase() !== 'doctor') {
      return res.status(403).json({ success: false, message: 'Only doctors can update doctor profiles' });
    }
    const userId = toId(req.user.id);
    const {
      specialization, experience, licenseNumber,
      consultationFee, availableDays, availableTime,
      degrees, clinicName, clinicAddress, consultationType, languages,
      profilePicture,
    } = req.body;

    const update = {};
    if (specialization !== undefined) update.specialization = specialization;
    if (experience !== undefined) update.experience_years = parseInt(experience) || 0;
    if (licenseNumber !== undefined) update.license_number = licenseNumber;
    if (consultationFee !== undefined) update.consultation_fee = parseFloat(consultationFee) || 0;
    if (availableDays !== undefined) update.available_days = availableDays;
    if (availableTime !== undefined) {
      update.available_hours = typeof availableTime === 'object'
        ? `${availableTime.start || ''} - ${availableTime.end || ''}`
        : availableTime;
    }
    if (degrees !== undefined) update.degrees = degrees;
    if (clinicName !== undefined) update.clinic_name = clinicName;
    if (clinicAddress !== undefined) update.clinic_address = clinicAddress;
    if (consultationType !== undefined) update.consultation_type = consultationType;
    if (languages !== undefined) update.languages = languages;

    const profile = await DoctorProfile.findOneAndUpdate(
      { user_id: userId },
      { $set: update },
      { new: true, upsert: true }
    );

    // Save profilePicture to User model so it's returned by /users/profile
    if (profilePicture !== undefined) {
      await User.findByIdAndUpdate(userId, { $set: { profilePicture } });
    }

    res.json({ success: true, message: 'Profile updated successfully', profile });
  } catch (error) {
    console.error('Update doctor profile error:', error);
    res.status(500).json({ success: false, message: 'Failed to update profile' });
  }
});

// ─── GET DOCTOR BY ID ─────────────────────────────────────────────────────────
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const id = toId(req.params.id);
    if (!id) return res.status(400).json({ success: false, message: 'Invalid doctor ID' });

    const user = await User.findOne({ _id: id, role: /^doctor$/i }).lean();
    if (!user) return res.status(404).json({ success: false, message: 'Doctor not found' });

    const profile = await DoctorProfile.findOne({ user_id: id }).lean() || {};

    res.json({
      success: true,
      doctor: {
        id: user._id.toString(),
        _id: user._id.toString(),
        name: user.username || user.name,
        email: user.email,
        phoneNumber: user.phone,
        role: user.role,
        specialization: profile.specialization,
        experience: profile.experience_years,
        licenseNumber: profile.license_number,
        consultationFee: profile.consultation_fee,
        availableDays: profile.available_days,
        availableTime: profile.available_hours,
        rating: profile.rating || 0,
        totalReviews: profile.total_reviews || 0,
      },
    });
  } catch (error) {
    console.error('Get doctor error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch doctor' });
  }
});

module.exports = router;
