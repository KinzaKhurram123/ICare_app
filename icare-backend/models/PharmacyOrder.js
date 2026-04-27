const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  product_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
  product_name: String,
  generic_name: String,
  quantity: { type: Number, default: 1 },
  price: { type: Number, default: 0 },
});

const pharmacyOrderSchema = new mongoose.Schema({
  patient_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  pharmacy_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  prescription_id: String,
  delivery_address: { type: String, default: '' },
  total_amount: { type: Number, default: 0 },
  delivery_fee: { type: Number, default: 0 },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'out-for-delivery', 'delivered', 'cancelled', 'completed'],
    default: 'pending',
  },
  order_number: String,
  expected_delivery_time: String,
  cancellation_reason: { type: String, default: '' },
  items: [orderItemSchema],
}, { timestamps: true });

module.exports = mongoose.models.PharmacyOrder || mongoose.model('PharmacyOrder', pharmacyOrderSchema);
