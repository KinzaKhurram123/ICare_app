const PatientHistoryForm = require('../models/PatientHistoryForm');
const Consultation = require('../models/Consultation');
const EnhancedPrescription = require('../models/EnhancedPrescription');

// Create patient history
exports.createPatientHistory = async (req, res) => {
  try {
    const historyData = req.body;

    // Validate required fields
    if (!historyData.patientId || !historyData.consultationId || !historyData.doctorId) {
      return res.status(400).json({
        success: false,
        message: 'Patient ID, Consultation ID, and Doctor ID are required'
      });
    }

    // Check if history already exists for this consultation
    let history = await PatientHistoryForm.findOne({
      consultationId: historyData.consultationId
    });

    if (history) {
      // Update existing history
      Object.assign(history, historyData);
      await history.save();

      return res.json({
        success: true,
        historyId: history._id,
        history,
        message: 'Patient history updated successfully'
      });
    }

    // Create new history
    history = new PatientHistoryForm(historyData);
    await history.save();

    // Update prescription with history reference if prescription exists
    const prescription = await EnhancedPrescription.findOne({
      consultationId: historyData.consultationId
    });

    if (prescription) {
      prescription.patientHistoryId = history._id;
      await prescription.save();
    }

    res.json({
      success: true,
      historyId: history._id,
      history,
      message: 'Patient history created successfully'
    });
  } catch (error) {
    console.error('Error creating patient history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create patient history',
      error: error.message
    });
  }
};

// Get patient history by patient ID
exports.getPatientHistory = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { limit = 10, skip = 0 } = req.query;

    const histories = await PatientHistoryForm.find({ patientId })
      .populate('doctorId', 'name specialization')
      .populate('consultationId', 'startTime endTime')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await PatientHistoryForm.countDocuments({ patientId });

    res.json({
      success: true,
      histories,
      count: histories.length,
      total
    });
  } catch (error) {
    console.error('Error getting patient history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get patient history',
      error: error.message
    });
  }
};

// Get history by consultation ID
exports.getHistoryByConsultation = async (req, res) => {
  try {
    const { consultationId } = req.params;

    const history = await PatientHistoryForm.findOne({ consultationId })
      .populate('patientId', 'name age gender')
      .populate('doctorId', 'name specialization');

    if (!history) {
      return res.json({
        success: true,
        history: null,
        message: 'No history found for this consultation'
      });
    }

    res.json({
      success: true,
      history
    });
  } catch (error) {
    console.error('Error getting history by consultation:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get history',
      error: error.message
    });
  }
};

// Get history by ID
exports.getHistoryById = async (req, res) => {
  try {
    const { historyId } = req.params;

    const history = await PatientHistoryForm.findById(historyId)
      .populate('patientId', 'name age gender email phone')
      .populate('doctorId', 'name specialization email phone')
      .populate('consultationId');

    if (!history) {
      return res.status(404).json({
        success: false,
        message: 'History not found'
      });
    }

    res.json({
      success: true,
      history
    });
  } catch (error) {
    console.error('Error getting history by ID:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get history',
      error: error.message
    });
  }
};

// Update patient history
exports.updatePatientHistory = async (req, res) => {
  try {
    const { historyId } = req.params;
    const updateData = req.body;

    const history = await PatientHistoryForm.findById(historyId);
    if (!history) {
      return res.status(404).json({
        success: false,
        message: 'History not found'
      });
    }

    // Update fields
    Object.assign(history, updateData);
    await history.save();

    res.json({
      success: true,
      history,
      message: 'Patient history updated successfully'
    });
  } catch (error) {
    console.error('Error updating patient history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update patient history',
      error: error.message
    });
  }
};

// Get latest history for patient
exports.getLatestHistory = async (req, res) => {
  try {
    const { patientId } = req.params;

    const history = await PatientHistoryForm.findOne({ patientId })
      .sort({ createdAt: -1 })
      .populate('doctorId', 'name specialization')
      .populate('consultationId', 'startTime');

    if (!history) {
      return res.json({
        success: true,
        history: null,
        message: 'No history found for this patient'
      });
    }

    res.json({
      success: true,
      history
    });
  } catch (error) {
    console.error('Error getting latest history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get latest history',
      error: error.message
    });
  }
};
