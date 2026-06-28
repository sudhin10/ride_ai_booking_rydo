const mongoose = require('mongoose');

// NOTE: mock/sandbox only. Never store real full PANs or CVV in production.
const cardSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    holderName: { type: String, required: true },
    brand: { type: String, enum: ['visa', 'mastercard', 'amex', 'other'], default: 'visa' },
    last4: { type: String, required: true, maxlength: 4 },
    expMonth: { type: Number, required: true, min: 1, max: 12 },
    expYear: { type: Number, required: true },
    isDefault: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Card', cardSchema);
