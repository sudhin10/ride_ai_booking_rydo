const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');

const EDITABLE = ['name', 'phone', 'avatarUrl', 'homeAddress', 'workAddress', 'emergencyContact'];
const PREFS = ['voiceNavigationEnabled', 'voiceNavigationPrompted', 'ttsSpeechRate'];

exports.updateProfile = asyncHandler(async (req, res) => {
  EDITABLE.forEach((f) => {
    if (req.body[f] !== undefined) req.user[f] = req.body[f];
  });
  await req.user.save();
  res.json({ success: true, user: req.user.toSafeJSON() });
});

exports.updatePreferences = asyncHandler(async (req, res) => {
  PREFS.forEach((f) => {
    if (req.body[f] !== undefined) req.user[f] = req.body[f];
  });
  await req.user.save();
  res.json({ success: true, user: req.user.toSafeJSON() });
});

exports.changePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const user = await User.findById(req.user._id).select('+password');
  const ok = await user.comparePassword(currentPassword);
  if (!ok) return res.status(400).json({ success: false, message: 'Current password incorrect' });
  user.password = newPassword;
  await user.save();
  return res.json({ success: true, message: 'Password changed' });
});

exports.topUpWallet = asyncHandler(async (req, res) => {
  const amount = Number(req.body.amount) || 0;
  req.user.walletBalance += amount;
  await req.user.save();
  res.json({ success: true, walletBalance: req.user.walletBalance });
});
