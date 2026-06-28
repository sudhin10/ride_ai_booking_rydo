"""Trains gradient-boosted models for fare and ETA prediction and saves them
with joblib. Run: python train.py"""
import joblib
import numpy as np
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

from data_gen import generate

NUM = ["distanceKm", "hour", "dayOfWeek", "demandLevel"]
CAT = ["rideType"]
MODEL_PATH = "models.joblib"


def _pipeline() -> Pipeline:
    pre = ColumnTransformer(
        [("cat", OneHotEncoder(handle_unknown="ignore"), CAT)],
        remainder="passthrough",
    )
    reg = GradientBoostingRegressor(n_estimators=200, max_depth=3, learning_rate=0.08)
    return Pipeline([("pre", pre), ("reg", reg)])


def train_and_save(df=None, path: str = MODEL_PATH):
    if df is None:
        df = generate()
    X = df[CAT + NUM]

    fare_pipe, eta_pipe = _pipeline(), _pipeline()
    Xtr, Xte, yf_tr, yf_te = train_test_split(X, df["fare"], test_size=0.2, random_state=1)
    _, _, ye_tr, ye_te = train_test_split(X, df["etaMin"], test_size=0.2, random_state=1)

    fare_pipe.fit(Xtr, yf_tr)
    eta_pipe.fit(Xtr, ye_tr)

    metrics = {
        "fare_mae": round(float(mean_absolute_error(yf_te, fare_pipe.predict(Xte))), 3),
        "fare_r2": round(float(r2_score(yf_te, fare_pipe.predict(Xte))), 3),
        "eta_mae": round(float(mean_absolute_error(ye_te, eta_pipe.predict(Xte))), 3),
        "eta_r2": round(float(r2_score(ye_te, eta_pipe.predict(Xte))), 3),
    }
    joblib.dump({"fare": fare_pipe, "eta": eta_pipe, "metrics": metrics}, path)
    return metrics


if __name__ == "__main__":
    m = train_and_save()
    print("Saved", MODEL_PATH)
    print("Metrics:", m)
