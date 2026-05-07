const Consultation = require('../models/Consultation');
const ConsultationMessage = require('../models/ConsultationMessage');
const EnhancedPrescription = require('../models/EnhancedPrescription');
const User = require('../models/User');
const { connectMongoDB } = require('../config/mongodb');

// Start consultation with appointment
exports.startConsultation = async (req, res) => {
  try {
    console.log('🔵 START CONSULTATION REQUEST:', JSON.stringify(req.body, null, 2));

    await connectMongoDB();
    const { appointmentId, patientId, doctorId, reason, channelName } = req.body;

    // Validate required fields
    if (!doctorId) {
      console.error('❌ Missing doctorId');
      return res.status(400).json({
        success: false,
        message: 'Doctor ID is required'
      });
    }

    if (!patientId) {
      console.error('❌ Missing patientId');
      return res.status(400).json({
        success: false,
        message: 'Patient ID is required'
      });
    }

    console.log('✅ Validation passed. Checking for existing consultation...');

    // Check if consultation already exists for this appointment
    if (appointmentId) {
      const existingConsultation = await Consultation.findOne({
        appointmentId,
        status: { $in: ['pending', 'active'] }
      });

      if (existingConsultation) {
        console.log('✅ Found existing consultation:', existingConsultation._id);
        return res.json({
          success: true,
          consultationId: existingConsultation._id,
          consultation: existingConsultation,
          message: 'Consultation already started'
        });
      }
    }

    console.log('✅ No existing consultation. Creating new one...');

    // Create new consultation
    const consultation = new Consultation({
      patientId,
      doctorId,
      appointmentId,
      channelName: channelName || `consultation_${Date.now()}_${patientId}`,
      reason: reason || 'Video consultation',
      status: 'active',
      startTime: new Date()
    });

    await consultation.save();
    console.log('✅ Consultation created:', consultation._id);

    // Get doctor details for consent message
    const doctor = await User.findById(doctorId);
    const doctorName = doctor ? doctor.name : 'Doctor';
    console.log('✅ Doctor found:', doctorName);

    // Auto-send consent message from doctor
    const consentMessage = new ConsultationMessage({
      consultationId: consultation._id,
      senderId: doctorId,
      senderName: doctorName,
      senderRole: 'doctor',
      message: `Hi, I am Dr. ${doctorName}. I confirm that telehealth has limitations and some emergencies require in-person visits.`,
      isSystemMessage: true,
      timestamp: new Date()
    });

    await consentMessage.save();
    console.log('✅ Consent message sent');

    res.json({
      success: true,
      consultationId: consultation._id,
      consultation,
      message: 'Consultation started successfully'
    });
  } catch (error) {
    console.error('❌ ERROR STARTING CONSULTATION:', error);
    console.error('❌ ERROR STACK:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Failed to start consultation',
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

// Send message
exports.sendMessage = async (req, res) => {
  try {
    await connectMongoDB();
    const { consultationId } = req.params;
    const { senderId, senderName, senderRole, message, attachmentUrl, isSystemMessage } = req.body;

    // Validate required fields
    if (!senderId || !senderName || !senderRole || !message) {
      return res.status(400).json({
        success: false,
        message: 'Sender ID, name, role, and message are required'
      });
    }

    // Verify consultation exists
    const consultation = await Consultation.findById(consultationId);
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: 'Consultation not found'
      });
    }

    // Create message
    const consultationMessage = new ConsultationMessage({
      consultationId,
      senderId,
      senderName,
      senderRole,
      message,
      attachmentUrl,
      isSystemMessage: isSystemMessage || false,
      timestamp: new Date()
    });

    await consultationMessage.save();

    res.json({
      success: true,
      messageId: consultationMessage._id,
      message: consultationMessage
    });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send message',
      error: error.message
    });
  }
};

// Get messages
exports.getMessages = async (req, res) => {
  try {
    await connectMongoDB();
    const { consultationId } = req.params;
    const { limit = 100, skip = 0 } = req.query;

    // Verify consultation exists
    const consultation = await Consultation.findById(consultationId);
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: 'Consultation not found'
      });
    }

    // Get messages
    const messages = await ConsultationMessage.find({ consultationId })
      .sort({ timestamp: 1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    res.json({
      success: true,
      messages,
      count: messages.length
    });
  } catch (error) {
    console.error('Error getting messages:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get messages',
      error: error.message
    });
  }
};

// End consultation
exports.endConsultation = async (req, res) => {
  try {
    await connectMongoDB();
    const { consultationId } = req.params;
    const { duration, prescriptionId } = req.body;

    // Verify consultation exists
    const consultation = await Consultation.findById(consultationId);
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: 'Consultation not found'
      });
    }

    // Check if consultation is already ended
    if (consultation.status === 'completed') {
      return res.json({
        success: true,
        message: 'Consultation already ended',
        consultation
      });
    }

    // Validate minimum duration (10 minutes = 600 seconds)
    if (duration && duration < 600) {
      return res.status(400).json({
        success: false,
        message: 'Consultation must be at least 10 minutes long'
      });
    }

    // Check if prescription is complete (for doctor)
    if (prescriptionId) {
      const prescription = await EnhancedPrescription.findById(prescriptionId);
      if (prescription && !prescription.isComplete) {
        return res.status(400).json({
          success: false,
          message: 'Prescription must be completed before ending consultation'
        });
      }
    }

    // Update consultation
    consultation.status = 'completed';
    consultation.endTime = new Date();
    consultation.duration = duration || Math.floor((consultation.endTime - consultation.startTime) / 1000);
    if (prescriptionId) {
      consultation.prescriptionId = prescriptionId;
      consultation.hasPrescription = true;
    }

    await consultation.save();

    // Send system message
    const systemMessage = new ConsultationMessage({
      consultationId,
      senderId: consultation.doctorId,
      senderName: 'System',
      senderRole: 'doctor',
      message: 'Consultation has ended.',
      isSystemMessage: true,
      timestamp: new Date()
    });

    await systemMessage.save();

    res.json({
      success: true,
      message: 'Consultation ended successfully',
      consultation,
      duration: consultation.duration
    });
  } catch (error) {
    console.error('Error ending consultation:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to end consultation',
      error: error.message
    });
  }
};

// Get consultation details
exports.getConsultation = async (req, res) => {
  try {
    await connectMongoDB();
    const { consultationId } = req.params;

    const consultation = await Consultation.findById(consultationId)
      .populate('patientId', 'name email phone')
      .populate('doctorId', 'name email phone specialization')
      .populate('prescriptionId');

    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: 'Consultation not found'
      });
    }

    res.json({
      success: true,
      consultation
    });
  } catch (error) {
    console.error('Error getting consultation:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get consultation',
      error: error.message
    });
  }
};

// Get consultation timer status
exports.getTimerStatus = async (req, res) => {
  try {
    await connectMongoDB();
    const { consultationId } = req.params;

    const consultation = await Consultation.findById(consultationId);
    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: 'Consultation not found'
      });
    }

    const now = new Date();
    const elapsed = Math.floor((now - consultation.startTime) / 1000);
    const minDuration = 600; // 10 minutes
    const maxDuration = 1800; // 30 minutes

    const canEnd = elapsed >= minDuration;
    const hasReachedMaximum = elapsed >= maxDuration;
    const remainingTime = maxDuration - elapsed;

    res.json({
      success: true,
      elapsed,
      canEnd,
      hasReachedMaximum,
      remainingTime: remainingTime > 0 ? remainingTime : 0,
      minDuration,
      maxDuration
    });
  } catch (error) {
    console.error('Error getting timer status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get timer status',
      error: error.message
    });
  }
};
