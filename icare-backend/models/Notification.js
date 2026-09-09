const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { 
    type: String, 
    // 'promotion' added for the Promotions & Offers feature: users already had a
    // notification preference for it, but there was no way to actually send one.
    enum: ['appointment', 'reminder', 'prescription', 'lab', 'message', 'payment', 'general', 'system', 'promotion'],
    default: 'general'
  },
  title: { type: String, required: true },
  message: { type: String, default: '' },
  read: { type: Boolean, default: false },
  data: { type: mongoose.Schema.Types.Mixed }, // optional metadata
  // Stable key (e.g. "cert_ready:<enrollmentId>") for the same logical
  // event, set by callers that want at-most-one notification per event
  // instead of a new doc every time a recheck fires. Left null on most
  // existing call sites — the sparse unique index only constrains docs
  // that actually set it.
  dedupKey: { type: String, default: null },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, dedupKey: 1 }, { unique: true, sparse: true });

module.exports = mongoose.models.Notification || mongoose.model('Notification', notificationSchema);