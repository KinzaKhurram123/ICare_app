const mongoose = require('mongoose');

const lessonSchema = new mongoose.Schema({
  title: String,
  content: { type: String, default: '' },
  videoUrl: String,          // Flutter sends videoUrl
  video_url: String,         // legacy alias
  duration: { type: Number, default: 0 },
  duration_minutes: { type: Number, default: 0 }, // legacy alias
  order: { type: Number, default: 0 },
  resources: { type: Array, default: [] },
});

const moduleSchema = new mongoose.Schema({
  title: String,
  description: { type: String, default: '' },
  order: { type: Number, default: 0 },
  lessons: [lessonSchema],
  quiz: { type: mongoose.Schema.Types.Mixed, default: null },
});

const courseSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, default: '' },

  // Thumbnail — accept both field names
  thumbnail: String,
  thumbnail_url: String,

  // Category & audience
  category: { type: String, default: 'HealthProgram' },
  targetAudience: { type: String, default: 'Patient' },
  difficulty: { type: String, default: null },
  healthConditions: { type: [String], default: [] },

  // Duration in hours
  duration: { type: Number, default: 0 },

  // Visibility / publish status
  visibility: {
    type: String,
    enum: ['public', 'private', 'assigned'],
    default: 'private',
  },
  isPublished: { type: Boolean, default: false },

  instructor_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  modules: [moduleSchema],
  assigned_to: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  is_active: { type: Boolean, default: true },
  rating: { type: Number, default: 0 },
  total_reviews: { type: Number, default: 0 },
}, { timestamps: true });

// Virtual: keep thumbnail consistent
courseSchema.pre('save', function (next) {
  if (this.thumbnail && !this.thumbnail_url) this.thumbnail_url = this.thumbnail;
  if (this.thumbnail_url && !this.thumbnail) this.thumbnail = this.thumbnail_url;
  if (this.isPublished && this.visibility === 'private') this.visibility = 'public';
  next();
});

module.exports = mongoose.models.Course || mongoose.model('Course', courseSchema);
