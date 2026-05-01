const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const DoctorProfile = require('../models/DoctorProfile');
const LabProfile = require('../models/LabProfile');
const PharmacyProfile = require('../models/PharmacyProfile');

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

    const user = await User.create({
      username,
      name: username,
      email: email.toLowerCase(),
      phone,
      password: hashedPassword,
      role,
      is_approved: isApproved,
      is_active: true,
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
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

module.exports = { register, login, getUserProfile };
