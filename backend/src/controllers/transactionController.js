const Transaction = require('../models/Transaction');
const asyncHandler = require('../utils/asyncHandler');

exports.list = asyncHandler(async (req, res) => {
  const txns = await Transaction.find({ user: req.user._id })
    .populate('ride')
    .sort({ createdAt: -1 });
  res.json({ success: true, transactions: txns });
});
