const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
  type: { 
    type: String, 
    enum: ['mcq', 'true_false', 'short_answer', 'essay'], 
    required: true 
  },
  question: { type: String, required: true },
  options: [String], // for MCQ
  correctAnswer: mongoose.Schema.Types.Mixed, // String or Array
  points: { type: Number, default: 1 },
  explanation: String,
  order: { type: Number, default: 0 }
});

const quizSchema = new mongoose.Schema({
  courseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
  moduleId: String,
  title: { type: String, required: true },
  description: String,
  questions: [questionSchema],
  timeLimit: Number, // minutes, null = no limit
  passingScore: { type: Number, default: 70 }, // percentage
  maxAttempts: { type: Number, default: 3 },
  shuffleQuestions: { type: Boolean, default: false },
  showCorrectAnswers: { type: Boolean, default: true },
  isPublished: { type: Boolean, default: true },
}, { timestamps: true });

module.exports = mongoose.models.Quiz || mongoose.model('Quiz', quizSchema);
