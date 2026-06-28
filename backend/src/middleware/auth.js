const { verifyAccessToken } = require('../utils/token');
const ApiError = require('../utils/ApiError');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');

const protect = asyncHandler(async (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) throw new ApiError(401, 'Not authorized, token missing');

  let payload;
  try {
    payload = verifyAccessToken(token);
  } catch (e) {
    throw new ApiError(401, 'Not authorized, token invalid or expired');
  }
  const user = await User.findById(payload.id);
  if (!user) throw new ApiError(401, 'User no longer exists');
  req.user = user;
  next();
});

const restrictTo = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return next(new ApiError(403, 'You do not have permission for this action'));
  }
  return next();
};

module.exports = { protect, restrictTo };
