-- ============================================================
-- 02_create_table_bronze.sql
-- Purpose : define Bronze layer schema — faithful to source
-- Layer   : Bronze (raw, nullable, no transformations)
-- Author  : erinardo-data
-- Date    : Sep 2026
-- ============================================================

USE medical_no_shows;
GO

-- Decision: all columns nullable — never block import on dirty data
-- Decision: TINYINT for binary flags (0/1) — 1 byte vs 4 bytes (INT)
-- Decision: dates as VARCHAR — convert to DATETIME2 in Silver layer
-- Decision: column sizes derived from real maxlen script (Python)

CREATE TABLE bronze_appointments (
    PatientID       VARCHAR(20),   -- max real: 15 chars — padded for safety
    AppointmentID   VARCHAR(20),   -- max real: 7 chars
    Gender          CHAR(1),       -- always 'M' or 'F' — fixed length
    ScheduledDay    VARCHAR(30),   -- ISO 8601 format: 2016-04-29T18:38:08Z
    AppointmentDay  VARCHAR(30),   -- faithful to source — pd.to_datetime() in Silver
    Age             INT,           -- min: -1 (anomaly) | max: 115 (anomaly) | avg: 37
    Neighbourhood   VARCHAR(100),  -- max real: 27 chars — padded for growth
    Scholarship     TINYINT,       -- 0/1 flag
    Hipertension    TINYINT,       -- 0/1 flag (source typo kept in Bronze)
    Diabetes        TINYINT,       -- 0/1 flag
    Alcoholism      TINYINT,       -- 0/1 flag
    Handcap         TINYINT,       -- 0/1 flag (source typo: Handicap fixed in Silver)
    SMS_received    TINYINT,       -- 0/1 flag
    NoShow          VARCHAR(3)     -- 'Yes' or 'No' — max: 3 chars
);
GO