const Card = require('../models/Card');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');

function detectBrand(number) {
  if (/^4/.test(number)) return 'visa';
  if (/^5[1-5]/.test(number)) return 'mastercard';
  if (/^3[47]/.test(number)) return 'amex';
  return 'other';
}

exports.list = asyncHandler(async (req, res) => {
  const cards = await Card.find({ user: req.user._id }).sort({ isDefault: -1, createdAt: -1 });
  res.json({ success: true, cards });
});

exports.add = asyncHandler(async (req, res) => {
  const { holderName, number, expMonth, expYear } = req.body;
  if (!number || number.replace(/\s/g, '').length < 12) throw new ApiError(400, 'Invalid card number');
  const clean = number.replace(/\s/g, '');
  const count = await Card.countDocuments({ user: req.user._id });
  const card = await Card.create({
    user: req.user._id,
    holderName,
    brand: detectBrand(clean),
    last4: clean.slice(-4),
    expMonth,
    expYear,
    isDefault: count === 0,
  });
  res.status(201).json({ success: true, card });
});

exports.setDefault = asyncHandler(async (req, res) => {
  await Card.updateMany({ user: req.user._id }, { isDefault: false });
  const card = await Card.findOneAndUpdate(
    { _id: req.params.id, user: req.user._id },
    { isDefault: true },
    { new: true }
  );
  if (!card) throw new ApiError(404, 'Card not found');
  res.json({ success: true, card });
});

exports.remove = asyncHandler(async (req, res) => {
  const card = await Card.findOneAndDelete({ _id: req.params.id, user: req.user._id });
  if (!card) throw new ApiError(404, 'Card not found');
  res.json({ success: true, message: 'Card removed' });
});
