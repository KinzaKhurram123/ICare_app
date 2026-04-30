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
const labSuppliesRoutes = require('./routes/lab-supplies');
const pharmacyRoutes = require('./routes/pharmacy');
const coursesRoutes = require('./routes/courses');
const productsRoutes = require('./routes/products');
const cartRoutes = require('./routes/cart');
const seedRoutes = require('./routes/seed');
const ratingsRoutes = require('./routes/ratings');
const inventoryRoutes = require('./routes/inventory');
const invoicesRoutes = require('./routes/invoices');
const usersRoutes = require('./routes/users');
const agoraRoutes = require('./routes/agora');
const callRoutes = require('./routes/call');
const connectNowRoutes = require('./routes/connect-now');
const instructorsRoutes = require('./routes/instructors');
const courseQuestionsRoutes = require('./routes/course-questions');
const callChatRoutes = require('./routes/call-chat');
const clinicalRoutes = require('./routes/clinical');

const app = express();

// Middleware
const corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
  credentials: false,
};
app.use(cors(corsOptions));

// Handle preflight for ALL routes explicitly
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  next();
});
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
app.use('/api/lab-supplies', labSuppliesRoutes);
app.use('/api/pharmacy', pharmacyRoutes);
app.use('/api/courses', coursesRoutes);

// Students courses — alias to instructors courses (public listing)
app.use('/api/students/courses', coursesRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/seed', seedRoutes);
app.use('/api/ratings', ratingsRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/invoices', invoicesRoutes);
app.use('/api/agora', agoraRoutes);
app.use('/api/call', callRoutes);
app.use('/api/connect-now', connectNowRoutes);
app.use('/api/instructors', instructorsRoutes);
app.use('/api/course-questions', courseQuestionsRoutes);

// Stub routes — return empty success so Flutter doesn't crash on 404
const makeStub = (emptyKey) => {
  const r = Router();
  r.all('/{*path}', (req, res) => res.json({ success: true, [emptyKey]: [], count: 0 }));
  r.all('/', (req, res) => res.json({ success: true, [emptyKey]: [], count: 0 }));
  return r;
};
app.use('/api/call-chat', callChatRoutes);
app.use('/api/chat', callChatRoutes); // alias
app.use('/api/users', usersRoutes);
app.use('/api/clinical', clinicalRoutes);

// ─── ICD CODES — standalone inline router (no auth required, local data) ─────
const ICD_DATA = [
  { code: 'A00', description: 'Cholera', category: 'I Certain infectious and parasitic diseases' },
  { code: 'A01', description: 'Typhoid and paratyphoid fevers', category: 'I Certain infectious and parasitic diseases' },
  { code: 'A09', description: 'Diarrhoea and gastroenteritis of infectious origin', category: 'I Certain infectious and parasitic diseases' },
  { code: 'A15', description: 'Respiratory tuberculosis', category: 'I Certain infectious and parasitic diseases' },
  { code: 'B01', description: 'Varicella (chickenpox)', category: 'I Certain infectious and parasitic diseases' },
  { code: 'B02', description: 'Zoster (herpes zoster)', category: 'I Certain infectious and parasitic diseases' },
  { code: 'B34', description: 'Viral infection of unspecified site', category: 'I Certain infectious and parasitic diseases' },
  { code: 'C18', description: 'Malignant neoplasm of colon', category: 'II Neoplasms' },
  { code: 'C34', description: 'Malignant neoplasm of bronchus and lung', category: 'II Neoplasms' },
  { code: 'C50', description: 'Malignant neoplasm of breast', category: 'II Neoplasms' },
  { code: 'D50', description: 'Iron deficiency anaemia', category: 'III Diseases of the blood and blood-forming organs' },
  { code: 'D64', description: 'Other anaemias', category: 'III Diseases of the blood and blood-forming organs' },
  { code: 'E10', description: 'Type 1 diabetes mellitus', category: 'IV Endocrine, nutritional and metabolic diseases' },
  { code: 'E11', description: 'Type 2 diabetes mellitus', category: 'IV Endocrine, nutritional and metabolic diseases' },
  { code: 'E14', description: 'Unspecified diabetes mellitus', category: 'IV Endocrine, nutritional and metabolic diseases' },
  { code: 'E66', description: 'Obesity', category: 'IV Endocrine, nutritional and metabolic diseases' },
  { code: 'E78', description: 'Disorders of lipoprotein metabolism', category: 'IV Endocrine, nutritional and metabolic diseases' },
  { code: 'F32', description: 'Depressive episode', category: 'V Mental and behavioural disorders' },
  { code: 'F41', description: 'Other anxiety disorders', category: 'V Mental and behavioural disorders' },
  { code: 'G43', description: 'Migraine', category: 'VI Diseases of the nervous system' },
  { code: 'G47', description: 'Sleep disorders', category: 'VI Diseases of the nervous system' },
  { code: 'H10', description: 'Conjunctivitis', category: 'VII Diseases of the eye and adnexa' },
  { code: 'H52', description: 'Disorders of refraction and accommodation', category: 'VII Diseases of the eye and adnexa' },
  { code: 'H65', description: 'Nonsuppurative otitis media', category: 'VIII Diseases of the ear and mastoid process' },
  { code: 'I10', description: 'Essential (primary) hypertension', category: 'IX Diseases of the circulatory system' },
  { code: 'I20', description: 'Angina pectoris', category: 'IX Diseases of the circulatory system' },
  { code: 'I21', description: 'Acute myocardial infarction', category: 'IX Diseases of the circulatory system' },
  { code: 'I25', description: 'Chronic ischaemic heart disease', category: 'IX Diseases of the circulatory system' },
  { code: 'I50', description: 'Heart failure', category: 'IX Diseases of the circulatory system' },
  { code: 'J00', description: 'Acute nasopharyngitis (common cold)', category: 'X Diseases of the respiratory system' },
  { code: 'J02', description: 'Acute pharyngitis', category: 'X Diseases of the respiratory system' },
  { code: 'J03', description: 'Acute tonsillitis', category: 'X Diseases of the respiratory system' },
  { code: 'J06', description: 'Acute upper respiratory infections', category: 'X Diseases of the respiratory system' },
  { code: 'J18', description: 'Pneumonia, unspecified organism', category: 'X Diseases of the respiratory system' },
  { code: 'J45', description: 'Asthma', category: 'X Diseases of the respiratory system' },
  { code: 'K21', description: 'Gastro-oesophageal reflux disease', category: 'XI Diseases of the digestive system' },
  { code: 'K25', description: 'Gastric ulcer', category: 'XI Diseases of the digestive system' },
  { code: 'K29', description: 'Gastritis and duodenitis', category: 'XI Diseases of the digestive system' },
  { code: 'K57', description: 'Diverticular disease of intestine', category: 'XI Diseases of the digestive system' },
  { code: 'L20', description: 'Atopic dermatitis', category: 'XII Diseases of the skin and subcutaneous tissue' },
  { code: 'L50', description: 'Urticaria', category: 'XII Diseases of the skin and subcutaneous tissue' },
  { code: 'M10', description: 'Gout', category: 'XIII Diseases of the musculoskeletal system' },
  { code: 'M15', description: 'Polyarthrosis', category: 'XIII Diseases of the musculoskeletal system' },
  { code: 'M54', description: 'Dorsalgia (back pain)', category: 'XIII Diseases of the musculoskeletal system' },
  { code: 'N18', description: 'Chronic kidney disease', category: 'XIV Diseases of the genitourinary system' },
  { code: 'N39', description: 'Other disorders of urinary system', category: 'XIV Diseases of the genitourinary system' },
  { code: 'R05', description: 'Cough', category: 'XVIII Symptoms, signs and abnormal findings' },
  { code: 'R50', description: 'Fever of other and unknown origin', category: 'XVIII Symptoms, signs and abnormal findings' },
  { code: 'R51', description: 'Headache', category: 'XVIII Symptoms, signs and abnormal findings' },
  { code: 'Z00', description: 'Encounter for general examination without complaint', category: 'XXI Factors influencing health status' },
];

const ICD_CATEGORIES = [
  'I Certain infectious and parasitic diseases',
  'II Neoplasms',
  'III Diseases of the blood and blood-forming organs',
  'IV Endocrine, nutritional and metabolic diseases',
  'V Mental and behavioural disorders',
  'VI Diseases of the nervous system',
  'VII Diseases of the eye and adnexa',
  'VIII Diseases of the ear and mastoid process',
  'IX Diseases of the circulatory system',
  'X Diseases of the respiratory system',
  'XI Diseases of the digestive system',
  'XII Diseases of the skin and subcutaneous tissue',
  'XIII Diseases of the musculoskeletal system',
  'XIV Diseases of the genitourinary system',
  'XV Pregnancy, childbirth and the puerperium',
  'XVI Certain conditions originating in the perinatal period',
  'XVII Congenital malformations and chromosomal abnormalities',
  'XVIII Symptoms, signs and abnormal findings',
  'XIX Injury, poisoning and external causes',
  'XX External causes of morbidity',
  'XXI Factors influencing health status',
  'XXII Codes for special purposes',
];

app.get('/api/icd-codes/search', (req, res) => {
  const query = (req.query.query || '').toLowerCase().trim();
  if (!query) return res.json({ success: true, results: [] });
  const results = ICD_DATA.filter(item =>
    item.code.toLowerCase().includes(query) ||
    item.description.toLowerCase().includes(query) ||
    item.category.toLowerCase().includes(query)
  );
  res.json({ success: true, results });
});

app.get('/api/icd-codes/categories', (req, res) => {
  res.json({ success: true, categories: ICD_CATEGORIES });
});

app.get('/api/icd-codes/category/:category', (req, res) => {
  const cat = req.params.category;
  const codes = ICD_DATA.filter(item => item.category === cat).map(({ code, description }) => ({ code, description }));
  res.json({ success: true, codes });
});

// assign-program stub
app.all('/api/clinical/assign-program', (req, res) => {
  res.json({ success: true, message: 'Program assigned successfully', programs: [] });
});

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
