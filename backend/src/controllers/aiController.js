const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const aiAssistant = require('../services/aiAssistantService');
const prediction = require('../services/predictionService');
const { isConfigured } = require('../services/openaiClient');

// POST /api/ai/assistant  { message }
exports.assistant = asyncHandler(async (req, res) => {
  const { message } = req.body;
  if (!message || !message.trim()) throw new ApiError(400, 'message is required');
  const context = {
    home: req.user?.homeAddress || null,
    work: req.user?.workAddress || null,
  };
  const result = await aiAssistant.handle(message.trim(), context);
  res.json({ success: true, result, aiEnabled: isConfigured() });
});

// POST /api/ai/predict-fare  { distanceKm, hour, dayOfWeek, rideType, demandLevel }
exports.predictFare = asyncHandler(async (req, res) => {
  const { distanceKm, hour, dayOfWeek, rideType, demandLevel } = req.body;
  if (distanceKm == null) throw new ApiError(400, 'distanceKm is required');
  const now = new Date();
  const prediction_ = await prediction.predict({
    distanceKm: Number(distanceKm),
    hour: hour ?? now.getHours(),
    dayOfWeek: dayOfWeek ?? now.getDay(),
    rideType: rideType || 'economy',
    demandLevel: demandLevel ?? 0.5,
  });
  res.json({ success: true, prediction: prediction_ });
});
