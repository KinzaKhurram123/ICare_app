const mongoose = require('mongoose');

const labTestRequestSchema = new mongoose.Schema({
  patient_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  lab_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  test_type: { type: String, required: true },
  test_date: String,
  price: { type: Number, default: 0 },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'sample_collected', 'sample-collected', 'awaiting_reports', 'reporting_done', 'processing', 'completed', 'cancelled'],
    default: 'pending',
  },
  results: mongoose.Schema.Types.Mixed,
  report_url: String,
  report_notes: String,
  medical_record_id: String,
  doctor_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
}, { timestamps: true });

module.exports = mongoose.models.LabTestRequest || mongoose.model('LabTestRequest', labTestRequestSchema);
