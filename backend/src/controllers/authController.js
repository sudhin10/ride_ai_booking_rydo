const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');
const { signAccessToken, signRefreshToken, verifyRefreshToken } = require('../utils/token');

function authPayload(user) {
  return {
    accessToken: signAccessToken(user),
    refreshToken: signRefreshToken(user),
    user: user.toSafeJSON(),
  };
}

exports.register = asyncHandler(async (req, res) => {
  const { name, email, password, phone } = req.body;
  const exists = await User.findOne({ email: email.toLowerCase() });
  if (exists) throw new ApiError(409, 'Email already registered');

  const user = await User.create({ name, email, password, phone });
  const payload = authPayload(user);
  user.refreshTokens = [payload.refreshToken];
  await user.save();
  res.status(201).json({ success: true, ...payload });
});

exports.login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email: email.toLowerCase() }).select('+password +refreshTokens');
  if (!user || !(await user.comparePassword(password))) {
    throw new ApiError(401, 'Invalid email or password');
  }
  const payload = authPayload(user);
  user.refreshTokens.push(payload.refreshToken);
  await user.save();
  res.json({ success: true, ...payload });
});

exports.refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) throw new ApiError(400, 'refreshToken required');
  let decoded;
  try {
    decoded = verifyRefreshToken(refreshToken);
  } catch (e) {
    throw new ApiError(401, 'Invalid refresh token');
  }
  const user = await User.findById(decoded.id).select('+refreshTokens');
  if (!user || !user.refreshTokens.includes(refreshToken)) {
    throw new ApiError(401, 'Refresh token revoked');
  }
  const newAccess = signAccessToken(user);
  res.json({ success: true, accessToken: newAccess });
});

exports.logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  const user = await User.findById(req.user._id).select('+refreshTokens');
  if (user && refreshToken) {
    user.refreshTokens = user.refreshTokens.filter((t) => t !== refreshToken);
    await user.save();
  }
  res.json({ success: true, message: 'Logged out' });
});

exports.me = asyncHandler(async (req, res) => {
  res.json({ success: true, user: req.user.toSafeJSON() });
});

// Mock "forgot password" — in production send an email with a reset token.
exports.forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email: email.toLowerCase() });
  // Always respond success to avoid user enumeration.
  res.json({
    success: true,
    message: 'If an account exists, a reset code has been sent.',
    ...(user ? { devResetCode: '123456' } : {}),
  });
});

exports.resetPassword = asyncHandler(async (req, res) => {
  const { email, code, newPassword } = req.body;
  if (code !== '123456') throw new ApiError(400, 'Invalid or expired reset code');
  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user) throw new ApiError(404, 'User not found');
  user.password = newPassword;
  await user.save();
  res.json({ success: true, message: 'Password updated' });
});
