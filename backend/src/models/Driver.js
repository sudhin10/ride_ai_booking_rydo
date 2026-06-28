const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    phone: { type: String, default: '' },
    avatarUrl: { type: String, default: '' },
    rating: { type: Number, default: 4.8, min: 0, max: 5 },
    totalTrips: { type: Number, default: 0 },
    car: {
      model: { type: String, default: 'Toyota Prius' },
      color: { type: String, default: 'White' },
      plate: { type: String, default: 'XYZ-0000' },
      type: { type: String, enum: ['economy', 'comfort', 'premium', 'van'], default: 'economy' },
    },
    isOnline: { type: Boolean, default: true },
    isAvailable: { type: Boolean, default: true },
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }, // [lng, lat]
    },
  },
  { timestamps: true }
);

driverSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Driver', driverSchema);
