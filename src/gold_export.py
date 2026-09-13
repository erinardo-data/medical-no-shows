# ============================================================
# gold_export.py
# Purpose : export Silver layer → Gold layer (3 formats)
# Input   : data/silver/appointments_silver.csv
# Output  : data/gold/appointments_gold.csv
#           data/gold/appointments_gold.xlsx
#           data/gold/appointments_gold.parquet
# Author  : erinardo-data
# Date    : Sep 2026
# ============================================================
# Decisions:
#   - CSV    → portability, human-readable, opens anywhere
#   - Excel  → non-technical stakeholders (directors, auditors)
#   - Parquet → international DE standard, native in Databricks
#   - UTC timezone dropped on export → tz-naive for Excel compat
# ============================================================

import pandas as pd
from pathlib import Path

# ── paths ────────────────────────────────────────────────────
BASE   = Path(__file__).resolve().parent.parent
SILVER = BASE / "data" / "silver" / "appointments_silver.csv"
GOLD   = BASE / "data" / "gold"

GOLD.mkdir(parents=True, exist_ok=True)

# ── load silver ───────────────────────────────────────────────
df = pd.read_csv(SILVER, parse_dates=['ScheduledDay', 'AppointmentDay'])
print(f"Silver loaded: {df.shape}")

# ── drop timezone for Excel compatibility ─────────────────────
df['ScheduledDay']   = df['ScheduledDay'].dt.tz_localize(None)
df['AppointmentDay'] = df['AppointmentDay'].dt.tz_localize(None)

# ── export 1: CSV ─────────────────────────────────────────────
out_csv = GOLD / "appointments_gold.csv"
df.to_csv(out_csv, index=False)
print(f"CSV saved    → {out_csv}")

# ── export 2: Excel ───────────────────────────────────────────
out_xlsx = GOLD / "appointments_gold.xlsx"
df.to_excel(out_xlsx, index=False, engine='openpyxl')
print(f"Excel saved  → {out_xlsx}")

# ── export 3: Parquet ─────────────────────────────────────────
out_parquet = GOLD / "appointments_gold.parquet"
df.to_parquet(out_parquet, index=False, engine='pyarrow', compression='snappy')
print(f"Parquet saved → {out_parquet}")

print(f"\nGold complete: {df.shape[0]:,} rows · 3 formats")