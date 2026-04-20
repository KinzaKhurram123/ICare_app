const express = require('express');
const cors = require('cors');
const Router = express.Router;
require('dotenv').config();

const authRoutes = require('./routes/auth');
const databaseRoutes = require('./routes/database');
const doctorsRoutes = require('./routes/doctors');
const appointmentsRoutes = require('./routes/appointments');
const medicalRecordsRoutes = require('./routes/medical-records');
const labsRoutes = require('./routes/labs');
const pharmacyRoutes = require('./routes/pharmacy');
const coursesRoutes = require('./routes/courses');
const productsRoutes = require('./routes/products');
const cartRoutes = require('./routes/cart');
const seedRoutes = require('./routes/seed');
const ratingsRoutes = require('./routes/ratings');
const inventoryRoutes = require('./routes/inventory');
const invoicesRoutes = require('./routes/invoices');
const usersRoutes = require('./routes/users');

const app = express();

// Middleware
const corsOptions = {
  origin: (origin, callback) => {
    // Allow all vercel.app subdomains, localhost, and no-origin requests (mobile/Postman)
    if (
      !origin ||
      /\.vercel\.app$/.test(origin) ||
      /^http:\/\/localhost(:\d+)?$/.test(origin) ||
      origin === 'https://icare-virtual-hospital.com' ||
      origin === 'https://www.icare-virtual-hospital.com'
    ) {
      callback(null, true);
    } else {
      callback(null, true); // Allow all during development — tighten in prod
    }
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
};
app.use(cors(corsOptions));
app.options('/{*path}', cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'iCare Backend API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'iCare API v1.0.0',
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      appointments: '/api/appointments',
      labs: '/api/labs',
      pharmacy: '/api/pharmacy',
      courses: '/api/courses'
    }
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/database', databaseRoutes);
app.use('/api/doctors', doctorsRoutes);
app.use('/api/appointments', appointmentsRoutes);
app.use('/api/medical-records', medicalRecordsRoutes);
app.use('/api/labs', labsRoutes);
app.use('/api/laboratories', labsRoutes);
app.use('/api/pharmacy', pharmacyRoutes);
app.use('/api/courses', coursesRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/seed', seedRoutes);
app.use('/api/ratings', ratingsRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/invoices', invoicesRoutes);

// Stub routes — return empty success so Flutter doesn't crash on 404
const makeStub = (emptyKey) => {
  const r = Router();
  r.all('/{*path}', (req, res) => res.json({ success: true, [emptyKey]: [], count: 0 }));
  r.all('/', (req, res) => res.json({ success: true, [emptyKey]: [], count: 0 }));
  return r;
};
app.use('/api/chat', makeStub('messages'));
app.use('/api/users', usersRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Export for Vercel serverless
module.exports = app;
