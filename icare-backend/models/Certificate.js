const mongoose = require('mongoose');

const certificateSchema = new mongoose.Schema({
  enrollmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Enrollment', required: true },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  courseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  certificateNumber: { type: String, required: true, unique: true },
  issuedAt: { type: Date, default: Date.now },
  pdfUrl: String,
  verificationCode: { type: String, required: true, unique: true },
  grade: String,
  finalScore: Number,
}, { timestamps: true });

// Generate certificate number: ICARE-YYYY-XXXXXX
certificateSchema.pre('save', function(next) {
  if (!this.certificateNumber) {
    const year = new Date().getFullYear();
    const random = Math.floor(100000 + Math.random() * 900000);
    this.certificateNumber = `ICARE-${year}-${random}`;
  }
  if (!this.verificationCode) {
    this.verificationCode = Math.random().toString(36).substring(2, 15).toUpperCase();
  }
  next();
});

module.exports = mongoose.models.Certificate || mongoose.model('Certificate', certificateSchema);
