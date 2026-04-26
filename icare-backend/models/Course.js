const mongoose = require('mongoose');

const lessonSchema = new mongoose.Schema({
  title: String,
  description: String,
  video_url: String,
  duration_minutes: { type: Number, default: 0 },
  order: { type: Number, default: 0 },
});

const moduleSchema = new mongoose.Schema({
  title: String,
  order: { type: Number, default: 0 },
  lessons: [lessonSchema],
});

const courseSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  thumbnail_url: String,
  visibility: { type: String, enum: ['public', 'private', 'assigned'], default: 'private' },
  instructor_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  modules: [moduleSchema],
  assigned_to: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  is_active: { type: Boolean, default: true },
  rating: { type: Number, default: 0 },
  total_reviews: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.models.Course || mongoose.model('Course', courseSchema);
