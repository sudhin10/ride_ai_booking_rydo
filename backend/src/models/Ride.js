const mongoose = require('mongoose');

const placeSchema = new mongoose.Schema(
  {
    address: { type: String, required: true },
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
  },
  { _id: false }
);

const rideSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    driver: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', default: null },
    pickup: { type: placeSchema, required: true },
    dropoff: { type: placeSchema, required: true },
    rideType: { type: String, enum: ['economy', 'comfort', 'premium', 'van'], default: 'economy' },
    status: {
      type: String,
      enum: ['requested', 'accepted', 'arriving', 'in_progress', 'completed', 'cancelled'],
      default: 'requested',
      index: true,
    },
    distanceKm: { type: Number, default: 0 },
    durationMin: { type: Number, default: 0 },
    fare: { type: Number, default: 0 },
    paymentMethod: { type: String, enum: ['card', 'cash', 'wallet'], default: 'card' },
    paymentStatus: { type: String, enum: ['pending', 'paid', 'failed'], default: 'pending' },
    route: { type: [[Number]], default: [] }, // array of [lat, lng]
    rating: { type: Number, default: null },
    riskScore: { type: Number, default: 0 },
    riskLevel: { type: String, enum: ['low', 'medium', 'high'], default: 'low' },
    riskFlags: { type: [String], default: [] },
    requestedAt: { type: Date, default: Date.now },
    completedAt: { type: Date, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Ride', rideSchema);
