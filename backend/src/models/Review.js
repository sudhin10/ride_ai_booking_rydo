const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    ride: { type: mongoose.Schema.Types.ObjectId, ref: 'Ride', default: null },
    driver: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', default: null },
    rating: { type: Number, min: 1, max: 5, default: 5 },
    text: { type: String, required: true, trim: true },
    sentiment: {
      label: { type: String, enum: ['positive', 'neutral', 'negative'], default: 'neutral' },
      score: { type: Number, default: 0 },
      summary: { type: String, default: '' },
      source: { type: String, default: 'lexicon' },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Review', reviewSchema);
