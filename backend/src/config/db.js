const mongoose = require('mongoose');
const env = require('./env');

async function connectDB() {
  mongoose.set('strictQuery', true);
  try {
    await mongoose.connect(env.mongoUri);
    // eslint-disable-next-line no-console
    console.log(`[db] Connected to MongoDB at ${env.mongoUri.replace(/\/\/.*@/, '//***@')}`);
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error('[db] Connection error:', err.message);
    process.exit(1);
  }
  mongoose.connection.on('disconnected', () => console.warn('[db] Disconnected'));
}

module.exports = connectDB;
