const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String },
  name: { type: String },
  email: { type: String, required: true, lowercase: true, trim: true },
  phone: { type: String },
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ['patient', 'doctor', 'lab', 'pharmacy', 'admin', 'instructor', 'student'],
    default: 'patient',
  },
  is_approved: { type: Boolean, default: true },
  is_active: { type: Boolean, default: true },
  // Virtual hospital compat fields
  isApproved: { type: Boolean, default: true },
  isActive: { type: Boolean, default: true },
}, {
  timestamps: true,
  strict: false, // Accept any extra fields from virtual hospital accounts
});

// Index for fast lookup
userSchema.index({ email: 1 });
userSchema.index({ username: 1 });

module.exports = mongoose.models.User || mongoose.model('User', userSchema);
