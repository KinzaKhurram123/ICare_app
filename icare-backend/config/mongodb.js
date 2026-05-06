const mongoose = require('mongoose');

// In serverless environments, reuse existing connection across warm invocations
const connectMongoDB = async () => {
  if (mongoose.connection.readyState === 1) return; // already connected
  if (mongoose.connection.readyState === 2) {
    // connecting — wait for it
    await new Promise((resolve, reject) => {
      mongoose.connection.once('connected', resolve);
      mongoose.connection.once('error', reject);
    });
    return;
  }
  const uri = (process.env.MONGO_URI || '').trim();
  if (!uri) {
    const err = new Error('MONGO_URI environment variable is not set');
    console.error('❌ MongoDB connection error:', err.message);
    throw err;
  }
  try {
    await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 5000,
      connectTimeoutMS: 5000,
      socketTimeoutMS: 30000,
      maxPoolSize: 5,
    });
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    throw err;
  }
};

module.exports = { connectMongoDB };
