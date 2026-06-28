const { getClient, isConfigured } = require('./openaiClient');
const env = require('../config/env');

/**
 * Classifies free-text ride reviews. Uses OpenAI when configured, otherwise a
 * transparent lexicon-based scorer so the feature always returns a result.
 */
const POSITIVE = ['great','good','excellent','amazing','clean','friendly','fast','smooth','safe','polite','comfortable','best','love','nice','perfect','on time','recommend'];
const NEGATIVE = ['bad','terrible','rude','dirty','late','slow','unsafe','awful','worst','hate','poor','cancelled','smell','dangerous','overpriced','rough'];

async function analyze(text) {
  if (isConfigured()) {
    try {
      return await viaOpenAI(text);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.warn('[sentiment] OpenAI failed, using lexicon:', e.message);
    }
  }
  return lexicon(text);
}

async function viaOpenAI(text) {
  const client = getClient();
  const completion = await client.chat.completions.create({
    model: env.openaiModel,
    temperature: 0,
    response_format: { type: 'json_object' },
    messages: [
      {
        role: 'system',
        content:
          'Classify the sentiment of a taxi ride review. Respond as JSON: {"label":"positive|neutral|negative","score":number between -1 and 1,"summary":"<=8 word gist"}.',
      },
      { role: 'user', content: text },
    ],
  });
  const parsed = JSON.parse(completion.choices[0].message.content);
  parsed.source = 'openai';
  return parsed;
}

function lexicon(text) {
  const t = (text || '').toLowerCase();
  let score = 0;
  POSITIVE.forEach((w) => { if (t.includes(w)) score += 1; });
  NEGATIVE.forEach((w) => { if (t.includes(w)) score -= 1; });
  const norm = Math.max(-1, Math.min(1, score / 3));
  let label = 'neutral';
  if (norm > 0.15) label = 'positive';
  else if (norm < -0.15) label = 'negative';
  return { label, score: Number(norm.toFixed(2)), summary: `${label} review`, source: 'lexicon' };
}

module.exports = { analyze };
