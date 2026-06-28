# AI Features

Rydo includes three distinct AI capabilities spanning **Generative AI (LLM)** and **classic Machine Learning** — chosen to showcase breadth for interviews/placements.

## 1. AI Ride Assistant (LLM — OpenAI)

A conversational assistant where the user types **or speaks** natural language such as *"Book a comfort ride to the airport at 6pm"*. The backend uses OpenAI (model from `OPENAI_MODEL`, default `gpt-4o-mini`) with a JSON-structured system prompt to extract a booking **intent** (`book_ride | ask_fare | smalltalk | help`) plus `pickup`, `dropoff`, `rideType`, and `when`. The app then deep-links straight into the booking flow with those fields pre-filled.

- **Backend:** `services/aiAssistantService.js`, `controllers/aiController.js`, `POST /api/ai/assistant`.
- **Frontend:** `screens/ai/ai_assistant_screen.dart` — chat UI with **voice input** (`speech_to_text`) and **voice output** (existing TTS / Voice Navigation). Opened from the **AI Assistant** button on the home map.
- **Graceful fallback:** if no `OPENAI_API_KEY` is set, a rule-based intent parser handles the request, so the feature still works and demos offline. The UI shows a `GPT` vs `Smart` badge to indicate which path is active.

## 2. Fare / ETA / Surge Prediction (ML — scikit-learn)

A standalone **Python FastAPI microservice** (`ml-service/`) serves two `GradientBoostingRegressor` models — one for **fare**, one for **ETA** — plus a demand-based **surge multiplier**. Models train on a synthetic dataset (`data_gen.py`) that mimics real demand patterns (rush hours, weekend nights, congestion-slowed speeds) and persist via joblib.

- **ML service:** `POST /predict` → `{ predictedFare, predictedEtaMin, surgeMultiplier, modelMetrics }`. Auto-trains on first start.
- **Backend proxy:** `services/predictionService.js` → `POST /api/ai/predict-fare`, with a deterministic fallback if the ML service is offline.
- **Frontend:** the **Choose a ride** screen shows an *"AI prediction: ~X min · $Y"* banner with surge awareness, refreshed per ride type.

## 3. Review Sentiment Analysis (NLP)

After a trip the rider can leave a free-text review. The backend classifies it as **positive / neutral / negative** with a score and short summary, stores it on the `Review` model, and exposes aggregate insights.

- **Backend:** `services/sentimentService.js` (OpenAI when configured, else a transparent lexicon scorer), `controllers/reviewController.js`, `POST /api/reviews`, `GET /api/reviews/insights`.
- **Frontend:** the **Trip Completed** screen shows the AI-detected sentiment chip right after submitting a review.

## Configuration

```env
OPENAI_API_KEY=sk-...      # optional; enables GPT path for assistant + sentiment
OPENAI_MODEL=gpt-4o-mini
ML_SERVICE_URL=http://127.0.0.1:8000
```

Everything degrades gracefully: with no API key and no ML service running, the app still functions end-to-end using the built-in fallbacks — useful for a guaranteed live demo.
