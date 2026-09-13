-- ============================================================
-- 01_create_database.sql
-- Purpose : provision project database and SQL Login
-- Author  : erinardo-data
-- Date    : Sep 2026
-- ============================================================

CREATE DATABASE medical_no_shows;
GO

USE medical_no_shows;
GO

-- SQL Login for programmatic Python/pyodbc access (WSL2)
-- Decision: SQL Login over Windows Auth — enables cross-environment access
CREATE LOGIN [erinardo-data] WITH PASSWORD = 'projetosqlmedical';
GO

CREATE USER [erinardo-data] FOR LOGIN [erinardo-data];
GO

ALTER ROLE db_owner ADD MEMBER [erinardo-data];
GO

-- Enable bulk insert permission
ALTER SERVER ROLE bulkadmin ADD MEMBER [erinardo-data];
GO