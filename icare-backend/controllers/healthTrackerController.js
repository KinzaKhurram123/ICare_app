const HealthTrackerEntry = require('../models/HealthTrackerEntry');
const UserHealthSettings = require('../models/UserHealthSettings');

// ═══════════════════════════════════════════════════════════════════════════
// ADD NEW VITAL ENTRY
// ═══════════════════════════════════════════════════════════════════════════
exports.addEntry = async (req, res) => {
  try {
    const { vitalType, value, unit, notes, timestamp } = req.body;
    const userId = req.user._id;

    // Validate required fields
    if (!vitalType || !value || !unit) {
      return res.status(400).json({
        success: false,
        message: 'Vital type, value, and unit are required',
      });
    }

    // Create new entry
    const entry = new HealthTrackerEntry({
      userId,
      vitalType,
      value,
      unit,
      notes: notes || '',
      timestamp: timestamp ? new Date(timestamp) : new Date(),
    });

    // Determine status based on value
    entry.status = entry.determineStatus();

    await entry.save();

    res.status(201).json({
      success: true,
      message: 'Vital entry added successfully',
      entry,
    });
  } catch (error) {
    console.error('Error adding vital entry:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add vital entry',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// GET ALL ENTRIES (WITH FILTERS)
// ═══════════════════════════════════════════════════════════════════════════
exports.getEntries = async (req, res) => {
  try {
    const userId = req.user._id;
    const { vitalType, startDate, endDate, limit = 100 } = req.query;

    // Build query
    const query = { userId };

    if (vitalType) {
      query.vitalType = vitalType;
    }

    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) query.timestamp.$gte = new Date(startDate);
      if (endDate) query.timestamp.$lte = new Date(endDate);
    }

    // Get entries
    const entries = await HealthTrackerEntry.find(query)
      .sort({ timestamp: -1 })
      .limit(parseInt(limit));

    res.json({
      success: true,
      count: entries.length,
      entries,
    });
  } catch (error) {
    console.error('Error fetching entries:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch entries',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// GET LATEST ENTRIES (ONE PER VITAL TYPE)
// ═══════════════════════════════════════════════════════════════════════════
exports.getLatestEntries = async (req, res) => {
  try {
    const userId = req.user._id;

    const latestEntries = await HealthTrackerEntry.getLatestEntries(userId);

    res.json({
      success: true,
      entries: latestEntries,
    });
  } catch (error) {
    console.error('Error fetching latest entries:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch latest entries',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// GET ENTRIES FOR SPECIFIC VITAL TYPE
// ═══════════════════════════════════════════════════════════════════════════
exports.getEntriesByType = async (req, res) => {
  try {
    const userId = req.user._id;
    const { vitalType } = req.params;
    const { days = 30 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const entries = await HealthTrackerEntry.find({
      userId,
      vitalType,
      timestamp: { $gte: startDate },
    }).sort({ timestamp: -1 });

    res.json({
      success: true,
      vitalType,
      count: entries.length,
      entries,
    });
  } catch (error) {
    console.error('Error fetching entries by type:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch entries',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// GET SUMMARY STATISTICS
// ═══════════════════════════════════════════════════════════════════════════
exports.getSummary = async (req, res) => {
  try {
    const userId = req.user._id;
    const { vitalType, days = 7 } = req.query;

    if (!vitalType) {
      return res.status(400).json({
        success: false,
        message: 'Vital type is required',
      });
    }

    const summary = await HealthTrackerEntry.getSummaryStats(
      userId,
      vitalType,
      parseInt(days)
    );

    res.json({
      success: true,
      vitalType,
      period: `${days} days`,
      summary,
    });
  } catch (error) {
    console.error('Error fetching summary:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch summary',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// UPDATE ENTRY
// ═══════════════════════════════════════════════════════════════════════════
exports.updateEntry = async (req, res) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    const { value, notes, timestamp } = req.body;

    const entry = await HealthTrackerEntry.findOne({ _id: id, userId });

    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found',
      });
    }

    // Update fields
    if (value) entry.value = value;
    if (notes !== undefined) entry.notes = notes;
    if (timestamp) entry.timestamp = new Date(timestamp);

    // Recalculate status
    entry.status = entry.determineStatus();

    await entry.save();

    res.json({
      success: true,
      message: 'Entry updated successfully',
      entry,
    });
  } catch (error) {
    console.error('Error updating entry:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update entry',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// DELETE ENTRY
// ═══════════════════════════════════════════════════════════════════════════
exports.deleteEntry = async (req, res) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const entry = await HealthTrackerEntry.findOneAndDelete({ _id: id, userId });

    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found',
      });
    }

    res.json({
      success: true,
      message: 'Entry deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting entry:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete entry',
      error: error.message,
    });
  }
};

// ═══════════════════════════════════════════════════════════════════════════
// GET DASHBOARD DATA (FOR HEALTH JOURNEY)
// ═══════════════════════════════════════════════════════════════════════════
exports.getDashboard = async (req, res) => {
  try {
    const userId = req.user._id;

    // Get user settings to determine which vitals to show
    const settings = await UserHealthSettings.getOrCreate(userId);
    const relevantVitals = settings.getRelevantVitals();

    // Map frontend vital names to database vital types
    const vitalTypeMap = {
      bloodPressure: 'Blood Pressure',
      bloodSugar: 'Blood Glucose',
      weight: 'Weight',
      water: 'Water Intake',
      medication: 'Medication Adherence',
      steps: 'Steps',
      sleep: 'Sleep',
      heartRate: 'Heart Rate',
      temperature: 'Temperature',
      oxygenLevel: 'Oxygen Level',
    };

    // Get latest entries for relevant vitals
    const dashboardData = await Promise.all(
      relevantVitals.map(async (vitalKey) => {
        const vitalType = vitalTypeMap[vitalKey];
        if (!vitalType) return null;

        const latestEntry = await HealthTrackerEntry.findOne({
          userId,
          vitalType,
        }).sort({ timestamp: -1 });

        const summary = await HealthTrackerEntry.getSummaryStats(userId, vitalType, 7);

        return {
          vitalKey,
          vitalType,
          latestEntry,
          summary,
        };
      })
    );

    res.json({
      success: true,
      healthModeEnabled: settings.healthModeEnabled,
      selectedConditions: settings.selectedConditions,
      vitals: dashboardData.filter((v) => v !== null),
    });
  } catch (error) {
    console.error('Error fetching dashboard:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard data',
      error: error.message,
    });
  }
};
