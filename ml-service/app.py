"""Rydo ML microservice — fare / ETA / surge prediction.

Run:
    pip install -r requirements.txt
    uvicorn app:app --reload --port 8000

On startup it loads models.joblib, training it first if absent. The Node
backend calls POST /predict; if this service is down the backend falls back to
its rule-based estimator, so the app keeps working either way.
"""
import os
import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from train import MODEL_PATH, train_and_save

app = FastAPI(title="Rydo ML Service", version="1.0.0")
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"]
)

TYPE_MULT = {"economy": 1.0, "comfort": 1.15, "premium": 1.4, "van": 1.3}
_models = None


def _load():
    global _models
    if _models is not None:
        return _models
    if not os.path.exists(MODEL_PATH):
        print("[ml] No model found — training on synthetic data...")
        train_and_save()
    _models = joblib.load(MODEL_PATH)
    print("[ml] Models loaded. Metrics:", _models.get("metrics"))
    return _models


class PredictRequest(BaseModel):
    distanceKm: float = Field(..., gt=0)
    hour: int = Field(default=12, ge=0, le=23)
    dayOfWeek: int = Field(default=1, ge=0, le=6)
    rideType: str = Field(default="economy")
    demandLevel: float = Field(default=0.5, ge=0, le=1)


@app.on_event("startup")
def startup():
    _load()


@app.get("/health")
def health():
    m = _load()
    return {"status": "ok", "metrics": m.get("metrics")}


@app.post("/predict")
def predict(req: PredictRequest):
    models = _load()
    rtype = req.rideType if req.rideType in TYPE_MULT else "economy"
    X = pd.DataFrame(
        [{
            "rideType": rtype,
            "distanceKm": req.distanceKm,
            "hour": req.hour,
            "dayOfWeek": req.dayOfWeek,
            "demandLevel": req.demandLevel,
        }]
    )
    fare = float(models["fare"].predict(X)[0])
    eta = float(models["eta"].predict(X)[0])
    surge = round(1 + max(0.0, req.demandLevel - 0.5) * 1.2, 2)
    return {
        "predictedFare": round(max(2.5, fare), 2),
        "predictedEtaMin": int(max(1, round(eta))),
        "surgeMultiplier": surge,
        "modelMetrics": models.get("metrics"),
    }
