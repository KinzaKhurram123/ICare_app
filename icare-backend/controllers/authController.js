const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const DoctorProfile = require('../models/DoctorProfile');
const LabProfile = require('../models/LabProfile');
const PharmacyProfile = require('../models/PharmacyProfile');

// ─── MR NUMBER GENERATOR ──────────────────────────────────────────────────────
// Format: MR-XXXXXX (6 uppercase alphanumeric chars, e.g. MR-A3F9K2)
const generateMrNumber = async () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I to avoid confusion
  let attempts = 0;
  while (attempts < 20) {
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars[Math.floor(Math.random() * chars.length)];
    }
    const mrNumber = `MR-${code}`;
    // Ensure uniqueness
    const exists = await User.findOne({ mrNumber }).lean();
    if (!exists) return mrNumber;
    attempts++;
  }
  // Fallback: use timestamp-based suffix
  return `MR-${Date.now().toString(36).toUpperCase().slice(-6)}`;
};

// ─── REGISTER ─────────────────────────────────────────────────────────────────
const register = async (req, res) => {
  try {
    await connectMongoDB();
    const { username: usernameField, name, email, phone, password, role: roleRaw } = req.body;
    const username = usernameField || name;
    const role = roleRaw?.toLowerCase();

    if (!username || !email || !password || !role) {
      return res.status(400).json({ success: false, message: 'Please provide all required fields' });
    }

    // Check existing
    const existing = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { username }],
    });
    if (existing) {
      return res.status(400).json({ success: false, message: 'User with this email or username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const rolesRequiringApproval = ['doctor', 'lab', 'pharmacy', 'instructor'];
    const isApproved = !rolesRequiringApproval.includes(role);

    // Auto-generate MR number for patients and students
    let mrNumber;
    if (role === 'patient' || role === 'student') {
      mrNumber = await generateMrNumber();
    }

    const user = await User.create({
      username,
      name: username,
      email: email.toLowerCase(),
      phone,
      password: hashedPassword,
      role,
      is_approved: isApproved,
      is_active: true,
      ...(mrNumber && { mrNumber }),
    });

    // Create role-specific profile
    if (role === 'doctor') {
      await DoctorProfile.create({ user_id: user._id });
    } else if (role === 'lab') {
      await LabProfile.create({ user_id: user._id });
    } else if (role === 'pharmacy') {
      await PharmacyProfile.create({ user_id: user._id });
    }

    const token = jwt.sign(
      { id: user._id.toString(), email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        token,
        user: {
          id: user._id.toString(),
          username: user.username,
          email: user.email,
          phone: user.phone,
          role: user.role,
          isApproved: user.is_approved,
          mrNumber: user.mrNumber || null,
        },
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
};

// ─── LOGIN ────────────────────────────────────────────────────────────────────
const login = async (req, res) => {
  try {
    await connectMongoDB();

    // Ensure admin exists on every login attempt (serverless-safe)
    const adminExists = await User.findOne({ email: 'admin@icare.com' }).lean();
    if (!adminExists) {
      const hashed = await bcrypt.hash('adminPassword123', 10);
      await User.create({
        username: 'Admin', name: 'Admin',
        email: 'admin@icare.com', password: hashed,
        role: 'admin', is_approved: true, is_active: true,
      }).catch(() => {}); // ignore duplicate key errors
    } else if (adminExists.role !== 'admin') {
      await User.findByIdAndUpdate(adminExists._id, { $set: { role: 'admin', is_active: true, is_approved: true } }).catch(() => {});
    }

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    // Find by email OR username
    const user = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { username: email }],
    });

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Check active
    const isActive = user.is_active !== false && user.isActive !== false;
    if (!isActive) {
      return res.status(403).json({ success: false, message: 'Your account has been deactivated' });
    }

    // Check approval for professional roles
    const rolesRequiringApproval = ['doctor', 'lab', 'pharmacy', 'instructor'];
    if (rolesRequiringApproval.includes(user.role?.toLowerCase()) && user.is_approved === false) {
      return res.status(403).json({ success: false, message: 'Your account is pending admin approval. Please wait for verification.' });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    // Auto-assign MR number to existing patients/students who don't have one yet
    if ((user.role === 'patient' || user.role === 'student') && !user.mrNumber) {
      try {
        const newMr = await generateMrNumber();
        await User.findByIdAndUpdate(user._id, { mrNumber: newMr });
        user.mrNumber = newMr;
      } catch (_) {}
    }

    const token = jwt.sign(
      { id: user._id.toString(), email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user._id.toString(),
          username: user.username || user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          isApproved: user.is_approved !== false && user.isApproved !== false,
          profilePicture: user.profilePicture || null,
          mrNumber: user.mrNumber || null,
        },
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
};

// ─── GET PROFILE ──────────────────────────────────────────────────────────────
const getUserProfile = async (req, res) => {
  try {
    await connectMongoDB();
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.status(200).json({
      success: true,
      user: {
        id: user._id.toString(),
        username: user.username || user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isApproved: user.is_approved !== false,
        mrNumber: user.mrNumber || null,
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

module.exports = { register, login, getUserProfile };
