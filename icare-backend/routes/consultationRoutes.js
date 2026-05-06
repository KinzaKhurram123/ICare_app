const express = require('express');
const router = express.Router();
const { authMiddleware: protect } = require('../middleware/auth');
const consultationController = require('../controllers/consultationController');
const multer = require('multer');
const path = require('path');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only images and PDFs are allowed'));
    }
  }
});

// Start consultation
router.post('/start', protect, consultationController.startConsultation);

// Get consultation details
router.get('/:consultationId', protect, consultationController.getConsultation);

// Send message
router.post('/:consultationId/messages', protect, consultationController.sendMessage);

// Get messages
router.get('/:consultationId/messages', protect, consultationController.getMessages);

// End consultation
router.post('/:consultationId/end', protect, consultationController.endConsultation);

// Upload attachment
router.post('/upload', protect, upload.single('file'), consultationController.uploadAttachment);

// Get my consultations
router.get('/', protect, consultationController.getMyConsultations);

module.exports = router;
