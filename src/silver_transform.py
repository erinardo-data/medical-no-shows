# ============================================================
# silver_transform.py
# Purpose : transform Bronze layer → Silver layer
# Input   : data/bronze/KaggleV2-May-2016.csv
# Output  : data/silver/appointments_silver.csv
# Author  : erinardo-data
# Date    : Sep 2026
# ============================================================
# Decisions:
#   - Age < 0 or Age > 100 → dropped (invalid values: -1, 115)
#   - Handcap → Handicap (source typo corrected)
#   - Hipertension → Hypertension (source typo corrected)
#   - Neighbourhoods with n < 30 → dropped (insufficient sample)
#   - ScheduledDay / AppointmentDay → parsed to datetime
#   - PatientID → converted from float64 to string
#   - NoShow → mapped to boolean (Yes=True, No=False)
#   - All columns enforced NOT NULL after cleaning
# ============================================================

import pandas as pd
from pathlib import Path

# ── paths ────────────────────────────────────────────────────
BASE  = Path(__file__).resolve().parent.parent
BRONZE = BASE / "data" / "bronze" / "KaggleV2-May-2016.csv"
SILVER = BASE / "data" / "silver" / "appointments_silver.csv"

# ── 1. load bronze ───────────────────────────────────────────
df = pd.read_csv(BRONZE)
print(f"Bronze loaded: {df.shape}")

# ── 2. rename columns (fix source typos) ─────────────────────
df = df.rename(columns={
    'Handcap':     'Handicap',
    'Hipertension': 'Hypertension',
    'No-show':     'NoShow'
})
print(f"Columns renamed: {list(df.columns)}")

# ── 3. fix PatientID — float64 → string ──────────────────────
df['PatientID'] = df['PatientId'].astype(str).str.replace('.0', '', regex=False)
df = df.drop(columns=['PatientId'])
print(f"PatientID sample: {df['PatientID'].head(3).tolist()}")

# ── 4. parse dates ────────────────────────────────────────────
df['ScheduledDay']    = pd.to_datetime(df['ScheduledDay'])
df['AppointmentDay']  = pd.to_datetime(df['AppointmentDay'])
print(f"Date types: {df[['ScheduledDay','AppointmentDay']].dtypes.tolist()}")

# ── 5. filter invalid ages ────────────────────────────────────
before = len(df)
df = df[(df['Age'] >= 0) & (df['Age'] <= 100)]
print(f"Age filter: {before - len(df)} rows dropped")

# ── 6. filter low-sample neighbourhoods (n < 30) ─────────────
counts = df['Neighbourhood'].value_counts()
valid  = counts[counts >= 30].index
before = len(df)
df = df[df['Neighbourhood'].isin(valid)]
print(f"Neighbourhood filter: {before - len(df)} rows dropped")

# ── 7. map NoShow → boolean ───────────────────────────────────
df['NoShow'] = df['NoShow'].map({'Yes': True, 'No': False})
print(f"NoShow dtype: {df['NoShow'].dtype}")

# ── 8. enforce NOT NULL ───────────────────────────────────────
before = len(df)
df = df.dropna()
print(f"Null drop: {before - len(df)} rows dropped")
print(f"Silver shape: {df.shape}")

# ── 9. save silver ────────────────────────────────────────────
SILVER.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(SILVER, index=False)
print(f"Silver saved → {SILVER}")