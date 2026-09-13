-- ============================================================
-- 04_eda_bronze.sql
-- Purpose : Exploratory Data Analysis on Bronze layer
-- Layer   : Bronze (read-only queries — no modifications)
-- Author  : erinardo-data
-- Date    : Sep 2026
-- ============================================================

USE medical_no_shows;
GO

-- ── 1. Confirm active connection ─────────────────────────────
SELECT DB_NAME() AS banco_atual;
GO

-- ── 2. Row count validation ───────────────────────────────────
SELECT COUNT(*) AS total_rows FROM bronze_appointments;
-- Result: 110527 ✓
GO

-- ── 3. Preview raw data ───────────────────────────────────────
SELECT TOP 5 * FROM bronze_appointments;
GO

-- ── 4. Age range — detect anomalies ──────────────────────────
SELECT
    MIN(Age) AS min_age,   -- Result: -1  ⚠ invalid — fix in Silver
    MAX(Age) AS max_age,   -- Result: 115 ⚠ unlikely — validate cutoff
    AVG(Age) AS avg_age    -- Result: 37  ✓ coherent
FROM bronze_appointments;
GO

-- ── 5. No-show distribution ───────────────────────────────────
SELECT
    NoShow,
    COUNT(*)                                    AS total,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER()
        AS DECIMAL(5,2)
    )                                           AS pct
FROM bronze_appointments
GROUP BY NoShow;
-- Result: Yes = 22319 (20.19%) | No = 88208 (79.81%)
-- Note: dataset is imbalanced 80/20 — relevant if ML is added later
GO

-- ── 6. No-show rate by neighbourhood (top 10) ─────────────────
SELECT TOP 10
    Neighbourhood,
    COUNT(*)                                            AS total,
    SUM(CASE WHEN NoShow = 'Yes' THEN 1 ELSE 0 END)    AS no_shows,
    CAST(
        SUM(CASE WHEN NoShow = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    )                                                   AS noshow_pct
FROM bronze_appointments
GROUP BY Neighbourhood
ORDER BY noshow_pct DESC;
-- Findings:
--   ILHAS OCEÂNICAS DE TRINDADE: 100% — n=2, statistically irrelevant (filter in Silver: n < 30)
--   SANTOS DUMONT: 28.92% — n=1276, highest reliable no-show rate
--   ANDORTNHAS: likely typo — correct to ANDORINHAS in Silver
GO