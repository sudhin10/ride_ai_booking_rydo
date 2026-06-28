const env = require('../config/env');

// 404 handler
function notFound(req, res, next) {
  res.status(404).json({ success: false, message: `Route not found: ${req.originalUrl}` });
}

// Central error handler
// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  let status = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';

  if (err.name === 'ValidationError') {
    status = 400;
    message = Object.values(err.errors).map((e) => e.message).join(', ');
  }
  if (err.code === 11000) {
    status = 409;
    message = `Duplicate value for: ${Object.keys(err.keyValue).join(', ')}`;
  }
  if (env.nodeEnv !== 'test') {
    // eslint-disable-next-line no-console
    console.error(`[error] ${status} ${message}`);
  }
  res.status(status).json({
    success: false,
    message,
    ...(env.nodeEnv === 'development' ? { stack: err.stack } : {}),
  });
}

module.exports = { notFound, errorHandler };
