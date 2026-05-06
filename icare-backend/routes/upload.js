const express = require('express');
const router = express.Router();
const multer = require('multer');
const { v2: cloudinary } = require('cloudinary');
const { authMiddleware: protect } = require('../middleware/auth');

// Use memory storage — Cloudinary uploads from buffer (Vercel-safe, no disk writes)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter(req, file, cb) {
    if (/jpeg|jpg|png|gif|webp|pdf/.test(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only images and PDFs are allowed'));
    }
  },
});

// Helper — upload buffer to Cloudinary
function uploadToCloudinary(buffer, folder, resourceType = 'image') {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: resourceType },
      (err, result) => (err ? reject(err) : resolve(result))
    );
    stream.end(buffer);
  });
}

// POST /api/upload/image  — general image upload (product photos, avatars, etc.)
router.post('/image', protect, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file provided' });
    }
    const folder = req.body.folder || 'icare/general';
    const result = await uploadToCloudinary(req.file.buffer, folder);
    res.json({ success: true, url: result.secure_url, publicId: result.public_id });
  } catch (err) {
    console.error('Upload error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/upload/prescription  — prescription image (patient/doctor side)
router.post('/prescription', protect, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file provided' });
    }
    const result = await uploadToCloudinary(req.file.buffer, 'icare/prescriptions');
    res.json({ success: true, url: result.secure_url, publicId: result.public_id });
  } catch (err) {
    console.error('Prescription upload error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/upload/product  — pharmacy product / medicine image
router.post('/product', protect, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file provided' });
    }
    const result = await uploadToCloudinary(req.file.buffer, 'icare/products');
    res.json({ success: true, url: result.secure_url, publicId: result.public_id });
  } catch (err) {
    console.error('Product upload error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
