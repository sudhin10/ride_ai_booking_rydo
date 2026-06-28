const { validationResult } = require('express-validator');
const ApiError = require('../utils/ApiError');

module.exports = function validate(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const msg = errors.array().map((e) => `${e.path}: ${e.msg}`).join('; ');
    return next(new ApiError(400, msg));
  }
  return next();
};
