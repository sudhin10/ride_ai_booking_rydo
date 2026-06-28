const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const Review = require('../models/Review');
const sentiment = require('../services/sentimentService');

// POST /api/reviews  { rideId?, driverId?, rating?, text }
exports.create = asyncHandler(async (req, res) => {
  const { rideId, driverId, rating, text } = req.body;
  if (!text || !text.trim()) throw new ApiError(400, 'Review text is required');
  const analysis = await sentiment.analyze(text.trim());
  const review = await Review.create({
    user: req.user._id,
    ride: rideId || null,
    driver: driverId || null,
    rating: rating || 5,
    text: text.trim(),
    sentiment: analysis,
  });
  res.status(201).json({ success: true, review });
});

// GET /api/reviews  -> user's reviews
exports.list = asyncHandler(async (req, res) => {
  const reviews = await Review.find({ user: req.user._id }).sort({ createdAt: -1 });
  res.json({ success: true, reviews });
});

// GET /api/reviews/insights -> aggregate sentiment breakdown
exports.insights = asyncHandler(async (req, res) => {
  const reviews = await Review.find({ user: req.user._id });
  const counts = { positive: 0, neutral: 0, negative: 0 };
  let total = 0;
  reviews.forEach((r) => {
    counts[r.sentiment.label] = (counts[r.sentiment.label] || 0) + 1;
    total += r.sentiment.score;
  });
  res.json({
    success: true,
    insights: {
      count: reviews.length,
      breakdown: counts,
      averageScore: reviews.length ? Number((total / reviews.length).toFixed(2)) : 0,
    },
  });
});
