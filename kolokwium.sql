-- Zad1
use master;
DROP DATABASE IF EXISTS pomiary;
CREATE DATABASE pomiary;
IF NOT EXISTS(SELECT 1 FROM sys.syslogins WHERE name = 'pomiar')
BEGIN
    CREATE LOGIN pomiar WITH PASSWORD = 'Passw0rd';
END
USE pomiary;
CREATE USER pomiar FOR LOGIN pomiar;
-- Zad2
GO
DROP TABLE IF EXISTS Measurements;
GO
CREATE TABLE Measurements (
    MeasurementTime DATETIME,
    CH4Concentration FLOAT,
    CO2Concentration FLOAT,
    PM1 FLOAT,
    PM2_5 FLOAT,
    PM10 FLOAT
);
GO
DROP PROCEDURE IF EXISTS LoadDataFromCSV;
GO
CREATE PROCEDURE LoadDataFromCSV
    @filePath NVARCHAR(500)
AS
BEGIN
    CREATE TABLE #TempTable (
        MeasurementTime DATETIME,
        Column2 FLOAT,
        Column3 FLOAT,
        Column4 FLOAT,
        Column5 INT,
        Column6 INT,
        Column7 INT,
        Column8 FLOAT,
        Column9 FLOAT,
        Column10 FLOAT,
        Column11 FLOAT,
        Column12 FLOAT,
        CH4Concentration FLOAT,
        PM1 FLOAT,
        PM2_5 FLOAT,
        PM10 FLOAT,
        Column17 INT,
        Column18 INT,
        Column19 INT,
        Column20 INT,
        Column21 INT,
        Column22 INT,
        CO2Concentration INT,
        Column24 FLOAT,
    );
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'BULK INSERT #TempTable FROM ''' + @filePath + ''' WITH (FIRSTROW = 1, FIELDTERMINATOR = '';'', ROWTERMINATOR = ''\n'')';
    EXEC sp_executesql @sql;
    INSERT INTO Measurements (MeasurementTime, CH4Concentration, CO2Concentration, PM1, PM2_5, PM10)
    SELECT MeasurementTime, CH4Concentration, CO2Concentration, PM1, PM2_5, PM10
    FROM #TempTable;
    DROP TABLE #TempTable;
END;
GO
EXEC LoadDataFromCSV 'C:\Users\Administrator\DataGripProjects\Databases2\pomiary2.csv';
GO
SELECT * FROM Measurements;
-- Zad3
GO
DROP FUNCTION IF EXISTS GetMeasurementStatsInIntervals;
GO
CREATE FUNCTION GetMeasurementStatsInIntervals(@startTime DATETIME, @endTime DATETIME)
RETURNS TABLE
AS
RETURN
(
    SELECT
        DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, MeasurementTime) / 10) * 10, 0) AS IntervalStart,
        COUNT(*) AS NumberOfMeasurements,
        MIN(CH4Concentration) AS MinCH4Concentration,
        MAX(CH4Concentration) AS MaxCH4Concentration,
        MIN(CO2Concentration) AS MinCO2Concentration,
        MAX(CO2Concentration) AS MaxCO2Concentration,
        MIN(PM1) AS MinPM1,
        MAX(PM1) AS MaxPM1,
        MIN(PM2_5) AS MinPM2_5,
        MAX(PM2_5) AS MaxPM2_5,
        MIN(PM10) AS MinPM10,
        MAX(PM10) AS MaxPM10
    FROM Measurements
    WHERE MeasurementTime BETWEEN @startTime AND @endTime
    GROUP BY DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, MeasurementTime) / 10) * 10, 0)
);
GO
SELECT *
FROM GetMeasurementStatsInIntervals('2021-08-09 00:00:00', '2021-08-09 01:00:00')
ORDER BY IntervalStart;
-- Zad4
GO
DROP FUNCTION IF EXISTS GetMeasurementsAsXML;
GO
CREATE FUNCTION GetMeasurementsAsXML(@startTime DATETIME, @endTime DATETIME)
RETURNS XML
AS
BEGIN
    RETURN (
        SELECT
            DATEADD(MINUTE, DATEDIFF(MINUTE, 0, MeasurementTime), 0) AS "@data",
            AVG(CH4Concentration) AS "ch4/@wart",
            AVG(CO2Concentration) AS "co2/@wart",
            AVG(PM1) AS "pm1/@wart",
            AVG(PM2_5) AS "pm2_5/@wart",
            AVG(PM10) AS "pm10/@wart"
        FROM Measurements
        WHERE MeasurementTime BETWEEN @startTime AND @endTime
        GROUP BY DATEADD(MINUTE, DATEDIFF(MINUTE, 0, MeasurementTime), 0)
        FOR XML PATH('pomiar'), ROOT('pomiary')
    );
END;
GO
SELECT dbo.GetMeasurementsAsXML('2021-08-09 00:00:00', '2021-08-09 01:00:00')
-- Zad5
GO
DROP PROCEDURE IF EXISTS GetCrossTabData;
GO
CREATE PROCEDURE GetCrossTabData @measurementType VARCHAR(50)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
        SELECT
            DATEPART(HOUR, MeasurementTime) AS Hour,
            MAX(' + QUOTENAME(@measurementType) + ') AS MaxValue,
            MIN(' + QUOTENAME(@measurementType) + ') AS MinValue,
            AVG(' + QUOTENAME(@measurementType) + ') AS AvgValue
        FROM Measurements
        GROUP BY DATEPART(HOUR, MeasurementTime)
        ORDER BY Hour';

    EXEC sp_executesql @sql;
END;
GO
EXEC GetCrossTabData 'CH4Concentration';