-- ============================================================
-- 03_bulk_insert_bronze.sql
-- Purpose : load raw CSV into Bronze table
-- Source  : C:\temp\KaggleV2-May-2016.csv (copied from WSL2)
-- Result  : 110,527 rows loaded in 0.15s
-- Author  : erinardo-data
-- Date    : Sep 2026
-- ============================================================

USE medical_no_shows;
GO

-- Pre-requisite: copy file from WSL2 to Windows before running
-- WSL2 command: cp data/bronze/KaggleV2-May-2016.csv /mnt/c/temp/
-- WSL2 command: sed -i '1s/No-show/NoShow/' /mnt/c/temp/KaggleV2-May-2016.csv

-- Decision: ROWTERMINATOR = '0x0a' (hex) not '\n' (text)
--           '\n' caused Msg 4866 on this dataset — hex is unambiguous
-- Decision: CODEPAGE = '65001' — declare UTF-8 explicitly
--           Required for Brazilian neighbourhood names with accents

BULK INSERT bronze_appointments
FROM 'C:\temp\KaggleV2-May-2016.csv'
WITH (
    FIRSTROW       = 2,        -- skip header row
    FIELDTERMINATOR = ',',     -- CSV standard delimiter
    ROWTERMINATOR  = '0x0a',   -- Unix line ending (hex — reliable)
    CODEPAGE       = '65001',  -- UTF-8 encoding
    TABLOCK                    -- table-level lock — faster bulk load
);
GO

-- Validate load
SELECT COUNT(*) AS total_rows FROM bronze_appointments;
-- Expected: 110527
GO