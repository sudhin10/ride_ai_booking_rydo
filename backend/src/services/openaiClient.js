const env = require('../config/env');

let client = null;

/**
 * Returns a singleton OpenAI client, or null when no API key is configured.
 * The 'openai' package is required lazily so the rule-based fallbacks work even
 * before `npm install` and without the dependency present.
 */
function getClient() {
  if (!env.openaiApiKey) return null;
  if (!client) {
    // eslint-disable-next-line global-require
    const OpenAI = require('openai');
    client = new OpenAI({ apiKey: env.openaiApiKey });
  }
  return client;
}

const isConfigured = () => Boolean(env.openaiApiKey);

module.exports = { getClient, isConfigured };
