const dotenv = require('dotenv');
dotenv.config();

const required = ['MONGO_URI', 'JWT_SECRET'];
const missing = required.filter((k) => !process.env[k]);
if (missing.length) {
  // eslint-disable-next-line no-console
  console.warn(`[env] Missing variables: ${missing.join(', ')} (using defaults where possible)`);
}

module.exports = {
  port: parseInt(process.env.PORT || '5000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  mongoUri: process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/rydo',
  jwtSecret: process.env.JWT_SECRET || 'dev_jwt_secret_change_me',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  refreshSecret: process.env.REFRESH_TOKEN_SECRET || 'dev_refresh_secret_change_me',
  refreshExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '30d',
  corsOrigins: (process.env.CORS_ORIGINS || '*').split(',').map((s) => s.trim()),
  openaiApiKey: process.env.OPENAI_API_KEY || '',
  openaiModel: process.env.OPENAI_MODEL || 'gpt-4o-mini',
  mlServiceUrl: process.env.ML_SERVICE_URL || 'http://127.0.0.1:8000',
};
