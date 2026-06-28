const { getClient, isConfigured } = require('./openaiClient');
const env = require('../config/env');

/**
 * Conversational ride assistant.
 * Uses OpenAI to (a) extract a structured booking intent from natural language
 * and (b) produce a friendly reply. Falls back to a rule-based parser so the
 * feature still works (and demos) without an API key.
 */

const RIDE_TYPES = ['economy', 'comfort', 'premium', 'van'];

const SYSTEM_PROMPT = `You are Rydo's in-app ride assistant.
The user may ask to book a ride, ask about fares, or chat about their trips.
Always reply briefly and helpfully. When the user wants to book a ride, extract
the destination (and pickup if given) and the preferred ride type.
Respond ONLY as compact JSON with this shape:
{
  "reply": "short natural language reply to show/speak to the user",
  "intent": "book_ride" | "ask_fare" | "smalltalk" | "help",
  "pickup": string | null,
  "dropoff": string | null,
  "rideType": "economy" | "comfort" | "premium" | "van" | null,
  "when": string | null
}`;

async function handle(message, context = {}) {
  if (isConfigured()) {
    try {
      return await viaOpenAI(message, context);
    } catch (e) {
      // fall through to heuristic on any API error
      // eslint-disable-next-line no-console
      console.warn('[ai] OpenAI failed, using fallback:', e.message);
    }
  }
  return heuristic(message);
}

async function viaOpenAI(message, context) {
  const client = getClient();
  const completion = await client.chat.completions.create({
    model: env.openaiModel,
    temperature: 0.3,
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      ...(context.home ? [{ role: 'system', content: `User home address: ${context.home}` }] : []),
      ...(context.work ? [{ role: 'system', content: `User work address: ${context.work}` }] : []),
      { role: 'user', content: message },
    ],
  });
  const raw = completion.choices[0].message.content;
  const parsed = JSON.parse(raw);
  parsed.source = 'openai';
  if (parsed.rideType && !RIDE_TYPES.includes(parsed.rideType)) parsed.rideType = 'economy';
  return parsed;
}

// --- Heuristic fallback (no external calls) ---
function heuristic(message) {
  const text = (message || '').toLowerCase();
  const result = {
    reply: '',
    intent: 'smalltalk',
    pickup: null,
    dropoff: null,
    rideType: null,
    when: null,
    source: 'fallback',
  };

  for (const t of RIDE_TYPES) {
    if (text.includes(t)) result.rideType = t;
  }

  const bookWords = ['book', 'ride', 'go to', 'take me', 'get me', 'drive', 'trip to'];
  const wantsBooking = bookWords.some((w) => text.includes(w));

  // crude destination extraction: text after "to"
  const toMatch = message.match(/\b(?:to|towards)\s+(.+?)(?:\s+(?:at|by|around|tonight|tomorrow|now)\b|[.?!]|$)/i);
  if (toMatch) result.dropoff = toMatch[1].trim();

  const timeMatch = message.match(/\b(at|around|by)\s+([0-9]{1,2}(:[0-9]{2})?\s*(am|pm)?)/i);
  if (timeMatch) result.when = timeMatch[2];

  if (wantsBooking || result.dropoff) {
    result.intent = 'book_ride';
    result.rideType ||= 'economy';
    result.reply = result.dropoff
      ? `Sure! I'll set up a ${result.rideType} ride to ${result.dropoff}${result.when ? ' at ' + result.when : ''}. Confirm to continue.`
      : 'Sure — where would you like to go?';
  } else if (text.includes('fare') || text.includes('cost') || text.includes('price')) {
    result.intent = 'ask_fare';
    result.reply = 'Tell me your destination and I will estimate the fare across all ride types.';
  } else if (text.includes('help') || text.includes('what can you')) {
    result.intent = 'help';
    result.reply = 'I can book rides, estimate fares, and answer questions about your trips. Try: "Book a comfort ride to the airport".';
  } else {
    result.reply = "I'm your Rydo assistant. I can book rides and estimate fares. Where would you like to go?";
  }
  return result;
}

module.exports = { handle };
