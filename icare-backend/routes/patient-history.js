const express = require('express');
const router = express.Router();
const patientHistoryController = require('../controllers/patientHistoryController');

// Create patient history
router.post('/create', patientHistoryController.createPatientHistory);

// Get patient history by patient ID
router.get('/patient/:patientId', patientHistoryController.getPatientHistory);

// Get history by consultation ID
router.get('/consultation/:consultationId', patientHistoryController.getHistoryByConsultation);

// Get history by ID
router.get('/:historyId', patientHistoryController.getHistoryById);

// Update patient history
router.put('/:historyId/update', patientHistoryController.updatePatientHistory);

// Get latest history for patient
router.get('/patient/:patientId/latest', patientHistoryController.getLatestHistory);

module.exports = router;
