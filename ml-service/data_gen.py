"""Generates a synthetic but realistic ride dataset for training the
fare / ETA / surge models. Real deployments would replace this with
historical trip data exported from MongoDB."""
import numpy as np
import pandas as pd

RIDE_TYPES = ["economy", "comfort", "premium", "van"]
TYPE_MULT = {"economy": 1.0, "comfort": 1.15, "premium": 1.4, "van": 1.3}


def generate(n: int = 6000, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    distance = rng.gamma(shape=2.2, scale=2.5, size=n).clip(0.4, 40)        # km
    hour = rng.integers(0, 24, size=n)
    dow = rng.integers(0, 7, size=n)                                        # 0=Sun
    rtype = rng.choice(RIDE_TYPES, size=n, p=[0.5, 0.25, 0.12, 0.13])
    base_demand = rng.uniform(0.1, 0.9, size=n)

    # Rush hours (8-10, 17-20) and weekend nights push demand up
    rush = np.isin(hour, [8, 9, 17, 18, 19]).astype(float) * 0.25
    weekend_night = ((np.isin(dow, [5, 6])) & (hour >= 21)).astype(float) * 0.2
    demand = (base_demand + rush + weekend_night).clip(0, 1)
    surge = 1 + np.clip(demand - 0.5, 0, None) * 1.2                        # up to ~1.6x

    mult = np.array([TYPE_MULT[t] for t in rtype])
    base_fare = 2.5 * mult
    per_km = 1.0 * mult
    noise = rng.normal(0, 1.0, size=n)
    fare = (base_fare + distance * per_km) * surge + noise
    fare = fare.clip(2.5, None)

    avg_speed = 34 - demand * 12                                           # congestion slows speed
    eta = (distance / avg_speed) * 60 + rng.normal(0, 1.5, size=n)
    eta = eta.clip(1, None)

    return pd.DataFrame({
        "distanceKm": distance,
        "hour": hour,
        "dayOfWeek": dow,
        "rideType": rtype,
        "demandLevel": demand,
        "surge": surge,
        "fare": fare,
        "etaMin": eta,
    })


if __name__ == "__main__":
    df = generate()
    df.to_csv("rides_dataset.csv", index=False)
    print(f"Wrote rides_dataset.csv with {len(df)} rows")
