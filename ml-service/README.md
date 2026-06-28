# Rydo ML Service (fare / ETA / surge prediction)

A FastAPI + scikit-learn microservice that predicts ride **fare**, **ETA**, and a
**surge multiplier** from trip features. Two `GradientBoostingRegressor` models
(one for fare, one for ETA) are trained on a synthetic dataset that mimics
real demand patterns (rush hours, weekend nights, congestion).

## Run

```bash
cd ml-service
python -m venv venv && source venv/bin/activate      # optional
pip install -r requirements.txt
python train.py            # optional — also auto-trains on first start
uvicorn app:app --port 8000
```

## Endpoints

| Method | Path | Body | Returns |
|-------|------|------|---------|
| GET | `/health` | – | status + model metrics |
| POST | `/predict` | `distanceKm, hour, dayOfWeek, rideType, demandLevel` | `predictedFare, predictedEtaMin, surgeMultiplier, modelMetrics` |

## How it connects

The Node backend (`backend/src/services/predictionService.js`) proxies to this
service via `ML_SERVICE_URL`. If it's unavailable, the backend falls back to a
deterministic estimator so the app still works.

## Files

- `data_gen.py` — synthetic dataset generator (swap for real exported trips).
- `train.py` — trains + evaluates (MAE / R²) and saves `models.joblib`.
- `app.py` — FastAPI server.
