const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { authMiddleware: auth } = require('../middleware/auth');

// ─── Schema ───────────────────────────────────────────────────────────────────
const voucherSchema = new mongoose.Schema({
  code:           { type: String, required: true, unique: true, uppercase: true, trim: true },
  instructorId:   { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  // What the code buys the student:
  //   'discount'    — money off, per discountType/discount below.
  //   'installment' — unlocks the course's installment plan for this student
  //                   alone. Installments used to be a course-wide switch, so
  //                   an instructor could only offer them to everybody or to
  //                   nobody; the client asked to be able to grant them the
  //                   same way a discount is granted.
  kind:           { type: String, enum: ['discount', 'installment'], default: 'discount' },
  // percent: discount is 1-100 (%). flat: discount is a fixed currency amount off.
  discountType:   { type: String, enum: ['percent', 'flat'], default: 'percent' },
  // Required for kind 'discount'; meaningless (and ignored) for 'installment'.
  discount:       { type: Number, default: 0, min: 0 },
  serviceType:    { type: String, enum: ['course'], default: 'course' }, // future: consultation/lab/pharmacy
  courseId:       { type: mongoose.Schema.Types.ObjectId, ref: 'Course', default: null }, // null = any course
  usedBy:         { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  usedAt:         { type: Date, default: null },
  expiresAt:      { type: Date, default: null },
  createdAt:      { type: Date, default: Date.now },
});

const Voucher = mongoose.models.Voucher || mongoose.model('Voucher', voucherSchema);

// Compute the final price after applying a voucher's discount to a base price.
function applyVoucherDiscount(voucher, basePrice) {
  const price = Number(basePrice) || 0;
  if (voucher.discountType === 'flat') {
    return Math.max(0, price - Number(voucher.discount));
  }
  const pct = Math.min(100, Math.max(0, Number(voucher.discount)));
  return Math.max(0, Math.round(price - (price * pct) / 100));
}

// ─── GET /api/vouchers — instructor: list own vouchers ────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const vouchers = await Voucher.find({ instructorId: req.user.id })
      .sort({ createdAt: -1 })
      .lean();
    res.json({ success: true, vouchers });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─── POST /api/vouchers — instructor creates a voucher ────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const { code, discount, discountType, courseId, expiresAt } = req.body;
    const kind = req.body.kind === 'installment' ? 'installment' : 'discount';
    if (!code) return res.status(400).json({ success: false, message: 'code is required' });
    if (kind === 'discount') {
      if (!discount) return res.status(400).json({ success: false, message: 'discount is required' });
      if (discountType === 'percent' && Number(discount) > 100) {
        return res.status(400).json({ success: false, message: 'Percent discount cannot exceed 100' });
      }
    } else if (!courseId) {
      // An installment code has to name its course: the plan (how many
      // payments, and when) lives on the course, so "any course" is not a
      // thing it can mean.
      return res.status(400).json({ success: false, message: 'An installment voucher must be tied to a course' });
    }

    const voucher = await Voucher.create({
      code: code.trim().toUpperCase(),
      instructorId: req.user.id,
      kind,
      discountType: discountType === 'flat' ? 'flat' : 'percent',
      discount: kind === 'discount' ? Number(discount) : 0,
      serviceType: 'course',
      courseId: courseId || null,
      expiresAt: expiresAt ? new Date(expiresAt) : null,
    });
    res.json({ success: true, voucher });
  } catch (err) {
    if (err.code === 11000) return res.status(409).json({ success: false, message: 'Voucher code already exists' });
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─── DELETE /api/vouchers/:id — instructor deletes own unused voucher ─────────
router.delete('/:id', auth, async (req, res) => {
  try {
    const v = await Voucher.findOne({ _id: req.params.id, instructorId: req.user.id });
    if (!v) return res.status(404).json({ success: false, message: 'Not found' });
    if (v.usedBy) return res.status(400).json({ success: false, message: 'Cannot delete a used voucher' });
    await v.deleteOne();
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─── POST /api/vouchers/validate — student validates a code before checkout ───
router.post('/validate', auth, async (req, res) => {
  try {
    const { code, courseId } = req.body;
    if (!code) return res.status(400).json({ success: false, message: 'code required' });

    const voucher = await Voucher.findOne({ code: code.trim().toUpperCase() });
    if (!voucher) return res.status(404).json({ success: false, message: 'Invalid voucher code' });
    if (voucher.usedBy) return res.status(400).json({ success: false, message: 'This voucher has already been used' });
    if (voucher.expiresAt && new Date() > voucher.expiresAt) return res.status(400).json({ success: false, message: 'Voucher has expired' });
    if (voucher.courseId && courseId && voucher.courseId.toString() !== courseId.toString()) {
      return res.status(400).json({ success: false, message: 'Voucher is not valid for this course' });
    }

    res.json({
      success: true,
      kind: voucher.kind || 'discount',
      discount: voucher.discount,
      discountType: voucher.discountType,
      voucherId: voucher._id,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─── POST /api/vouchers/redeem — mark voucher as used on enrollment ───────────
router.post('/redeem', auth, async (req, res) => {
  try {
    const { code, courseId } = req.body;
    if (!code) return res.status(400).json({ success: false, message: 'code required' });

    const voucher = await Voucher.findOne({ code: code.trim().toUpperCase() });
    if (!voucher) return res.status(404).json({ success: false, message: 'Invalid voucher code' });
    if (voucher.usedBy) return res.status(400).json({ success: false, message: 'Voucher already used' });
    if (voucher.expiresAt && new Date() > voucher.expiresAt) return res.status(400).json({ success: false, message: 'Voucher expired' });
    if (voucher.courseId && courseId && voucher.courseId.toString() !== courseId.toString()) {
      return res.status(400).json({ success: false, message: 'Voucher not valid for this course' });
    }

    voucher.usedBy = req.user.id;
    voucher.usedAt = new Date();
    await voucher.save();

    res.json({ success: true, kind: voucher.kind || 'discount', discount: voucher.discount, discountType: voucher.discountType });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
module.exports.Voucher = Voucher;
module.exports.applyVoucherDiscount = applyVoucherDiscount;
