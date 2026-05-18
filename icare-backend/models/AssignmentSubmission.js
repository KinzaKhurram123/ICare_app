const mongoose = require('mongoose');

const submissionSchema = new mongoose.Schema({
  assignmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Assignment', required: true },
  courseId:     { type: mongoose.Schema.Types.ObjectId, ref: 'Course',     required: true },
  studentId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User',       required: true },
  content:      { type: String, default: '' },       // text answer
  fileUrl:      { type: String },                    // uploaded file (Cloudinary)
  fileName:     { type: String },
  marksObtained:{ type: Number, default: null },
  feedback:     { type: String, default: '' },
  status:       { type: String, enum: ['submitted', 'graded', 'late'], default: 'submitted' },
  submittedAt:  { type: Date, default: Date.now },
  gradedAt:     { type: Date },
  gradedBy:     { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
}, { timestamps: true });

submissionSchema.index({ assignmentId: 1, studentId: 1 }, { unique: true });

module.exports = mongoose.models.AssignmentSubmission || mongoose.model('AssignmentSubmission', submissionSchema);
