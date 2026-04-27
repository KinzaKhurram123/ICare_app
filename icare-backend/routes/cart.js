const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { connectMongoDB } = require('../config/mongodb');
const User = require('../models/User');
const Product = require('../models/Product');
const CartItem = require('../models/CartItem');
const PharmacyOrder = require('../models/PharmacyOrder');
const { authMiddleware } = require('../middleware/auth');

function toId(id) {
  try { return new mongoose.Types.ObjectId(id); } catch { return null; }
}

// ─── GET CART ─────────────────────────────────────────────────────────────────
router.get('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const cartItems = await CartItem.find({ user_id: userId }).sort({ createdAt: -1 }).lean();

    const productIds = cartItems.map(c => c.product_id);
    const products = await Product.find({ _id: { $in: productIds }, is_active: true }).lean();
    const pMap = {};
    products.forEach(p => { pMap[p._id.toString()] = p; });

    const pharmacyIds = [...new Set(products.map(p => p.pharmacy_id.toString()))];
    const pharmacies = await User.find({ _id: { $in: pharmacyIds.map(id => toId(id)) } }).lean();
    const phMap = {};
    pharmacies.forEach(p => { phMap[p._id.toString()] = p; });

    let total = 0;
    const cart = cartItems.map(c => {
      const p = pMap[c.product_id.toString()];
      if (!p) return null;
      total += (p.price || 0) * c.quantity;
      return {
        id: c._id.toString(),
        _id: c._id.toString(),
        quantity: c.quantity,
        createdAt: c.createdAt,
        product_id: p._id.toString(),
        name: p.name,
        description: p.description,
        price: p.price,
        stock_quantity: p.stock_quantity,
        requires_prescription: p.requires_prescription,
        medicine_category: p.medicine_category,
        generic_name: p.generic_name,
        pharmacy_name: phMap[p.pharmacy_id.toString()]?.username || phMap[p.pharmacy_id.toString()]?.name,
        pharmacy_id: p.pharmacy_id.toString(),
      };
    }).filter(Boolean);

    res.status(200).json({ success: true, cart, total: total.toFixed(2), count: cart.length });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch cart' });
  }
});

// ─── ADD TO CART ──────────────────────────────────────────────────────────────
router.post('/add', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { productId, quantity, prescriptionId } = req.body;

    if (!productId || !quantity || quantity < 1) {
      return res.status(400).json({ success: false, message: 'Product ID and valid quantity are required' });
    }

    const product = await Product.findOne({ _id: toId(productId), is_active: true }).lean();
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    // Controlled/Vaccine check
    if (product.medicine_category === 'Controlled' || product.medicine_category === 'Vaccine') {
      if (!prescriptionId) {
        return res.status(400).json({
          success: false,
          message: 'This medicine can only be purchased online after consultation with our doctor. It is mandatory to have a consultation with our doctor.',
          requiresConsultation: true,
          medicineCategory: product.medicine_category,
        });
      }
    }

    // 30-unit cap
    if (!prescriptionId && quantity > 30) {
      return res.status(400).json({
        success: false,
        message: 'Maximum 30 units allowed per order without prescription. Please consult with our doctor for larger quantities.',
        maxQuantity: 30,
        requiresConsultation: true,
      });
    }

    if (product.stock_quantity < quantity) {
      return res.status(400).json({ success: false, message: 'Insufficient stock' });
    }

    const existing = await CartItem.findOne({ user_id: userId, product_id: toId(productId) });

    let cartItem;
    if (existing) {
      const newQuantity = existing.quantity + quantity;
      if (!prescriptionId && newQuantity > 30) {
        return res.status(400).json({
          success: false,
          message: 'Maximum 30 units allowed per order without prescription',
          maxQuantity: 30,
          currentQuantity: existing.quantity,
          requiresConsultation: true,
        });
      }
      if (product.stock_quantity < newQuantity) {
        return res.status(400).json({ success: false, message: 'Insufficient stock for requested quantity' });
      }
      existing.quantity = newQuantity;
      if (prescriptionId) existing.prescription_id = prescriptionId;
      await existing.save();
      cartItem = existing;
    } else {
      cartItem = await CartItem.create({
        user_id: userId,
        product_id: toId(productId),
        quantity,
        prescription_id: prescriptionId || null,
      });
    }

    res.status(200).json({ success: true, message: 'Item added to cart', cartItem: { ...cartItem.toObject(), _id: cartItem._id.toString() } });
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({ success: false, message: 'Failed to add item to cart' });
  }
});

// ─── UPDATE CART ITEM ─────────────────────────────────────────────────────────
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { quantity, prescriptionId } = req.body;

    if (!quantity || quantity < 1) {
      return res.status(400).json({ success: false, message: 'Valid quantity is required' });
    }

    const cartItem = await CartItem.findOne({ _id: toId(req.params.id), user_id: userId });
    if (!cartItem) {
      return res.status(404).json({ success: false, message: 'Cart item not found' });
    }

    const product = await Product.findById(cartItem.product_id).lean();

    if (!prescriptionId && quantity > 30) {
      return res.status(400).json({
        success: false,
        message: 'Maximum 30 units allowed per order without prescription',
        maxQuantity: 30,
        requiresConsultation: true,
      });
    }

    if (product && product.stock_quantity < quantity) {
      return res.status(400).json({ success: false, message: 'Insufficient stock' });
    }

    cartItem.quantity = quantity;
    await cartItem.save();

    res.status(200).json({ success: true, message: 'Cart updated', cartItem: { ...cartItem.toObject(), _id: cartItem._id.toString() } });
  } catch (error) {
    console.error('Update cart error:', error);
    res.status(500).json({ success: false, message: 'Failed to update cart' });
  }
});

// ─── REMOVE ITEM ──────────────────────────────────────────────────────────────
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const item = await CartItem.findOneAndDelete({ _id: toId(req.params.id), user_id: userId });
    if (!item) {
      return res.status(404).json({ success: false, message: 'Cart item not found' });
    }
    res.status(200).json({ success: true, message: 'Item removed from cart' });
  } catch (error) {
    console.error('Remove from cart error:', error);
    res.status(500).json({ success: false, message: 'Failed to remove item' });
  }
});

// ─── CLEAR CART ───────────────────────────────────────────────────────────────
router.delete('/', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    await CartItem.deleteMany({ user_id: toId(req.user.id) });
    res.status(200).json({ success: true, message: 'Cart cleared' });
  } catch (error) {
    console.error('Clear cart error:', error);
    res.status(500).json({ success: false, message: 'Failed to clear cart' });
  }
});

// ─── CHECKOUT ─────────────────────────────────────────────────────────────────
router.post('/checkout', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const userId = toId(req.user.id);
    const { deliveryAddress, pharmacyId } = req.body;

    if (!deliveryAddress) {
      return res.status(400).json({ success: false, message: 'Delivery address is required' });
    }

    const cartItems = await CartItem.find({ user_id: userId }).lean();
    if (cartItems.length === 0) {
      return res.status(400).json({ success: false, message: 'Cart is empty' });
    }

    const productIds = cartItems.map(c => c.product_id);
    const products = await Product.find({ _id: { $in: productIds }, is_active: true }).lean();
    const pMap = {};
    products.forEach(p => { pMap[p._id.toString()] = p; });

    let totalAmount = 0;
    const selectedPharmacyId = toId(pharmacyId) || products[0]?.pharmacy_id;
    const orderItems = [];

    for (const item of cartItems) {
      const product = pMap[item.product_id.toString()];
      if (!product) continue;
      if (product.stock_quantity < item.quantity) {
        return res.status(400).json({ success: false, message: `Insufficient stock for ${product.name}` });
      }
      totalAmount += (product.price || 0) * item.quantity;
      orderItems.push({
        product_id: product._id,
        product_name: product.name,
        generic_name: product.generic_name,
        quantity: item.quantity,
        price: product.price,
      });
    }

    const orderNumber = `ORD-${Date.now().toString().slice(-8)}`;
    const order = await PharmacyOrder.create({
      patient_id: userId,
      pharmacy_id: selectedPharmacyId,
      total_amount: totalAmount,
      delivery_address: deliveryAddress,
      status: 'pending',
      order_number: orderNumber,
      items: orderItems,
    });

    // Update stock
    for (const item of cartItems) {
      await Product.findByIdAndUpdate(item.product_id, { $inc: { stock_quantity: -item.quantity } });
    }

    // Clear cart
    await CartItem.deleteMany({ user_id: userId });

    res.status(201).json({ success: true, message: 'Order placed successfully', order: { ...order.toObject(), _id: order._id.toString() } });
  } catch (error) {
    console.error('Checkout error:', error);
    res.status(500).json({ success: false, message: 'Failed to place order' });
  }
});

module.exports = router;
