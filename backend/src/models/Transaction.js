const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    ride: { type: mongoose.Schema.Types.ObjectId, ref: 'Ride', default: null },
    type: { type: String, enum: ['ride_payment', 'topup', 'refund'], default: 'ride_payment' },
    amount: { type: Number, required: true },
    method: { type: String, enum: ['card', 'cash', 'wallet'], default: 'card' },
    status: { type: String, enum: ['pending', 'success', 'failed'], default: 'success' },
    reference: { type: String, default: '' },
    description: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Transaction', transactionSchema);
