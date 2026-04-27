const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const PharmacyProfile = require('../models/PharmacyProfile');
const Product = require('../models/Product');
const PharmacyOrder = require('../models/PharmacyOrder');
const { authMiddleware } = require('../middleware/auth');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

// ─── GET ALL PHARMACIES ───────────────────────────────────────────────────────
router.get('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const users = await User.find({ role: 'pharmacy', is_active: { $ne: false } }).lean();
    const ids = users.map(u => u._id);
    const profiles = await PharmacyProfile.find({ user_id: { $in: ids } }).lean();
    const pMap = {};
    profiles.forEach(p => { pMap[p.user_id.toString()] = p; });

    const pharmacies = users.map(u => {
      const p = pMap[u._id.toString()] || {};
      return {
        id: u._id.toString(), _id: u._id.toString(),
        name: u.username || u.name, email: u.email, phone: u.phone,
        pharmacy_name: p.pharmacy_name, license_number: p.license_number,
        operating_hours: p.operating_hours, delivery_available: p.delivery_available,
        delivery_fee: p.delivery_fee,
      };
    });
    res.json({ success: true, pharmacies });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to fetch pharmacies' });
  }
});

router.get('/get_all_pharmacy', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const users = await User.find({ role: 'pharmacy', is_active: { $ne: false } }).lean();
    const ids = users.map(u => u._id);
    const profiles = await PharmacyProfile.find({ user_id: { $in: ids } }).lean();
    const pMap = {};
    profiles.forEach(p => { pMap[p.user_id.toString()] = p; });

    const pharmacies = users.map(u => {
      const p = pMap[u._id.toString()] || {};
      return {
        id: u._id.toString(), _id: u._id.toString(),
        name: u.username || u.name, email: u.email, phone: u.phone,
        pharmacy_name: p.pharmacy_name, license_number: p.license_number,
        operating_hours: p.operating_hours, delivery_available: p.delivery_available,
        delivery_fee: p.delivery_fee,
      };
    });
    res.json({ success: true, pharmacies });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to fetch pharmacies' });
  }
});

// ─── PHARMACY PROFILE GET ─────────────────────────────────────────────────────
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const user = await User.findById(userId).lean();
    const profile = await PharmacyProfile.findOne({ user_id: userId }).lean() || {};

    res.json({
      success: true,
      pharmacy: {
        id: user._id.toString(), _id: user._id.toString(),
        username: user.username || user.name, email: user.email, phone: user.phone,
        ...profile,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to fetch profile' });
  }
});

// ─── PHARMACY PROFILE UPSERT ──────────────────────────────────────────────────
router.post('/add_pharmacy_details', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { pharmacyName, licenseNumber, operatingHours, deliveryAvailable, deliveryFee, address, city, drapCompliance } = req.body;

    const profile = await PharmacyProfile.findOneAndUpdate(
      { user_id: userId },
      {
        $set: {
          pharmacy_name: pharmacyName, license_number: licenseNumber,
          operating_hours: operatingHours, delivery_available: deliveryAvailable ?? false,
          delivery_fee: deliveryFee ?? 0, address, city,
          drap_compliance: drapCompliance ?? false,
        },
      },
      { new: true, upsert: true }
    );

    res.json({ success: true, pharmacy: profile, existingProfile: profile });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to update pharmacy details' });
  }
});

// ─── PHARMACY PROFILE PUT ─────────────────────────────────────────────────────
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const update = {};
    const { pharmacyName, licenseNumber, operatingHours, deliveryAvailable, deliveryFee, address, city, drapCompliance } = req.body;
    if (pharmacyName) update.pharmacy_name = pharmacyName;
    if (licenseNumber) update.license_number = licenseNumber;
    if (operatingHours) update.operating_hours = operatingHours;
    if (deliveryAvailable !== undefined) update.delivery_available = deliveryAvailable;
    if (deliveryFee !== undefined) update.delivery_fee = deliveryFee;
    if (address) update.address = address;
    if (city) update.city = city;
    if (drapCompliance !== undefined) update.drap_compliance = drapCompliance;

    if (Object.keys(update).length === 0) {
      return res.status(400).json({ success: false, message: 'No fields to update' });
    }

    const profile = await PharmacyProfile.findOneAndUpdate(
      { user_id: userId },
      { $set: update },
      { new: true, upsert: true }
    );
    res.json({ success: true, profile });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to update pharmacy profile' });
  }
});

// ─── STATS ────────────────────────────────────────────────────────────────────
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [orders, products] = await Promise.all([
      PharmacyOrder.find({ pharmacy_id: userId }).lean(),
      Product.find({ pharmacy_id: userId, is_active: true }).lean(),
    ]);

    const todayOrders = orders.filter(o => new Date(o.createdAt) >= today).length;
    const totalOrders = orders.length;
    const pendingOrders = orders.filter(o => o.status === 'pending').length;
    const completedOrders = orders.filter(o => ['delivered', 'completed'].includes(o.status)).length;
    const totalProducts = products.length;
    const lowStock = products.filter(p => (p.stock_quantity ?? 0) < 30).length;
    const revenue = orders
      .filter(o => ['delivered', 'completed'].includes(o.status))
      .reduce((sum, o) => sum + (o.total_amount || 0), 0);

    res.json({ success: true, todayOrders, totalOrders, pendingOrders, completedOrders, totalProducts, lowStock, revenue: Math.round(revenue) });
  } catch (err) {
    console.error(err);
    res.json({ success: true, todayOrders: 0, totalOrders: 0, pendingOrders: 0, completedOrders: 0, totalProducts: 0, lowStock: 0, revenue: 0 });
  }
});

// ─── ANALYTICS ────────────────────────────────────────────────────────────────
router.get('/analytics', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const orders = await PharmacyOrder.find({ pharmacy_id: userId }).lean();
    const totalRevenue = orders.filter(o => ['delivered', 'completed'].includes(o.status)).reduce((s, o) => s + (o.total_amount || 0), 0);
    const totalOrders = orders.length;
    const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
    res.json({ success: true, totalRevenue: Math.round(totalRevenue), totalOrders, averageOrderValue: parseFloat(avgOrderValue.toFixed(2)), topSellingProducts: [] });
  } catch (err) {
    console.error(err);
    res.json({ success: true, totalRevenue: 0, totalOrders: 0, averageOrderValue: 0, topSellingProducts: [] });
  }
});

// ─── GET ORDERS (list for pharmacy) ──────────────────────────────────────────
router.get('/orders/pharmacy/list', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { status } = req.query;
    const query = { pharmacy_id: userId };
    if (status && status !== 'all') query.status = status;

    const rawOrders = await PharmacyOrder.find(query).sort({ createdAt: -1 }).lean();
    const patientIds = [...new Set(rawOrders.map(o => o.patient_id.toString()))];
    const patients = await User.find({ _id: { $in: patientIds.map(id => toId(id)) } }).lean();
    const pMap = {};
    patients.forEach(p => { pMap[p._id.toString()] = p; });

    const orders = rawOrders.map(o => ({
      _id: o._id.toString(),
      orderNumber: o.order_number || `#${o._id.toString().slice(-6).toUpperCase()}`,
      status: o.status,
      totalAmount: o.total_amount || 0,
      deliveryFee: o.delivery_fee || 0,
      deliveryAddress: o.delivery_address,
      expectedDeliveryTime: o.expected_delivery_time,
      createdAt: o.createdAt,
      prescriptionId: o.prescription_id,
      user: {
        _id: pMap[o.patient_id.toString()]?._id?.toString(),
        name: pMap[o.patient_id.toString()]?.username || pMap[o.patient_id.toString()]?.name || 'Patient',
        email: pMap[o.patient_id.toString()]?.email,
        phoneNumber: pMap[o.patient_id.toString()]?.phone,
      },
      items: o.items || [],
    }));

    res.json({ success: true, orders });
  } catch (err) {
    console.error(err);
    res.json({ success: true, orders: [] });
  }
});

router.get('/orders', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const userRole = req.user.role;
    const { status } = req.query;

    const query = userRole === 'pharmacy' ? { pharmacy_id: userId } : { patient_id: userId };
    if (status && status !== 'all') query.status = status;

    const orders = await PharmacyOrder.find(query).sort({ createdAt: -1 }).lean();
    res.json({ success: true, orders: orders.map(o => ({ ...o, _id: o._id.toString() })) });
  } catch (err) {
    console.error(err);
    res.json({ success: true, orders: [] });
  }
});

// ─── GET ORDER BY ID ──────────────────────────────────────────────────────────
router.get('/orders/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const orderId = toId(req.params.id);
    if (!orderId) return res.status(400).json({ success: false, message: 'Invalid order ID' });

    const order = await PharmacyOrder.findOne({
      _id: orderId,
      $or: [{ patient_id: userId }, { pharmacy_id: userId }],
    }).lean();

    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    res.json({ success: true, order: { ...order, _id: order._id.toString() } });
  } catch (err) {
    console.error('GET /pharmacy/orders/:id error:', err.message);
    res.status(500).json({ success: false, message: 'Failed to fetch order' });
  }
});

// ─── CREATE ORDER ─────────────────────────────────────────────────────────────
router.post('/orders', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();

    const patientId = toId(req.user.id);
    if (!patientId) return res.status(401).json({ success: false, message: 'Invalid patient token' });

    const { pharmacyId, userId: bodyUserId, prescriptionId, deliveryAddress, totalAmount, deliveryFee, items } = req.body;

    // Accept either pharmacyId or userId (frontend may send either)
    const rawPharmacyId = pharmacyId || bodyUserId;
    if (!rawPharmacyId) return res.status(400).json({ success: false, message: 'pharmacyId is required' });

    const resolvedPharmacyId = toId(rawPharmacyId);
    if (!resolvedPharmacyId) return res.status(400).json({ success: false, message: `Invalid pharmacy ID: ${rawPharmacyId}` });

    // Normalize items — frontend may send productName or product_name
    const normalizedItems = Array.isArray(items) ? items.map(i => ({
      product_name: i.product_name || i.productName || i.name || '',
      generic_name: i.generic_name || i.genericName || '',
      quantity: Number(i.quantity) || 1,
      price: Number(i.price) || 0,
    })) : [];

    // Generate unique order number with random suffix to avoid collisions
    const orderNumber = `ORD-${Date.now().toString().slice(-8)}-${Math.random().toString(36).slice(-4).toUpperCase()}`;

    const order = await PharmacyOrder.create({
      patient_id: patientId,
      pharmacy_id: resolvedPharmacyId,
      prescription_id: prescriptionId || undefined,
      delivery_address: deliveryAddress || '',
      total_amount: Number(totalAmount) || 0,
      delivery_fee: Number(deliveryFee) || 0,
      status: 'pending',
      order_number: orderNumber,
      items: normalizedItems,
    });

    res.status(201).json({ success: true, message: 'Order created successfully', order: { ...order.toObject(), _id: order._id.toString() } });
  } catch (err) {
    console.error('POST /pharmacy/orders error:', err.message, err.stack);
    // Return the actual error message so the client can display it
    res.status(500).json({ success: false, message: err.message || 'Failed to create order' });
  }
});

// ─── UPDATE ORDER STATUS ──────────────────────────────────────────────────────
router.put('/update_order_status/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { status, expectedDeliveryTime } = req.body;

    const validStatuses = ['pending', 'confirmed', 'preparing', 'out-for-delivery', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const update = { status };
    if (expectedDeliveryTime) update.expected_delivery_time = expectedDeliveryTime;

    const order = await PharmacyOrder.findOneAndUpdate(
      { _id: toId(req.params.id), $or: [{ patient_id: userId }, { pharmacy_id: userId }] },
      { $set: update },
      { new: true }
    );

    if (!order) return res.status(404).json({ success: false, message: 'Order not found or access denied' });
    res.json({ success: true, message: 'Order updated successfully', order: { ...order.toObject(), _id: order._id.toString() } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to update order' });
  }
});

router.put('/orders/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { status, expectedDeliveryTime } = req.body;

    const validStatuses = ['pending', 'confirmed', 'preparing', 'out-for-delivery', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const update = { status };
    if (expectedDeliveryTime) update.expected_delivery_time = expectedDeliveryTime;

    const order = await PharmacyOrder.findOneAndUpdate(
      { _id: toId(req.params.id), $or: [{ patient_id: userId }, { pharmacy_id: userId }] },
      { $set: update },
      { new: true }
    );

    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    res.json({ success: true, message: 'Order updated', order: { ...order.toObject(), _id: order._id.toString() } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to update order' });
  }
});

// ─── CANCEL ORDER ─────────────────────────────────────────────────────────────
router.put('/orders/:id/cancel', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const order = await PharmacyOrder.findOneAndUpdate(
      { _id: toId(req.params.id), patient_id: userId, status: { $in: ['pending', 'confirmed'] } },
      { $set: { status: 'cancelled', cancellation_reason: req.body.reason || '' } },
      { new: true }
    );
    if (!order) return res.status(404).json({ success: false, message: 'Order not found or cannot be cancelled' });
    res.json({ success: true, message: 'Order cancelled', order: { ...order.toObject(), _id: order._id.toString() } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to cancel order' });
  }
});

// ─── PRODUCTS ─────────────────────────────────────────────────────────────────
router.get('/products', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { pharmacyId, category, q } = req.query;
    const uid = toId(pharmacyId || req.user.id);
    const query = { pharmacy_id: uid, is_active: true };
    if (category && category !== 'All') query.category = category;

    let products = await Product.find(query).lean();

    if (q) {
      const lq = q.toLowerCase();
      products = products.filter(p => p.name?.toLowerCase().includes(lq) || p.description?.toLowerCase().includes(lq));
    }

    res.json({ success: true, medicines: products.map(p => ({ ...p, _id: p._id.toString() })) });
  } catch (err) {
    console.error(err);
    res.json({ success: true, medicines: [] });
  }
});

router.post('/products', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { name, description, category, price, stockQuantity, manufacturer, requiresPrescription, genericName } = req.body;

    const product = await Product.create({
      pharmacy_id: userId, name, description, category: category || 'OTC',
      price: price || 0, stock_quantity: stockQuantity || 0,
      manufacturer, requires_prescription: requiresPrescription ?? false, generic_name: genericName,
    });

    res.status(201).json({ success: true, medicine: { ...product.toObject(), _id: product._id.toString() } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to create product' });
  }
});

router.put('/products/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { name, price, stockQuantity, category, description } = req.body;
    const update = {};
    if (name) update.name = name;
    if (price !== undefined) update.price = price;
    if (stockQuantity !== undefined) update.stock_quantity = stockQuantity;
    if (category) update.category = category;
    if (description) update.description = description;

    if (Object.keys(update).length === 0) {
      return res.status(400).json({ success: false, message: 'Nothing to update' });
    }

    const product = await Product.findByIdAndUpdate(req.params.id, { $set: update }, { new: true });
    res.json({ success: true, medicine: { ...product.toObject(), _id: product._id.toString() } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to update product' });
  }
});

router.delete('/products/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    await Product.findByIdAndUpdate(req.params.id, { is_active: false });
    res.json({ success: true, message: 'Product deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to delete product' });
  }
});

module.exports = router;
