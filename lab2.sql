------------------------ ZADANIE Z1

-- podpunkt a

CREATE TABLE CopyTable (
    RowNumber INT
)
DECLARE @currentNumber INT = 0;
WHILE @currentNumber <= 100
BEGIN
    INSERT INTO CopyTable (RowNumber)
    VALUES (@currentNumber);
    SET @currentNumber = @currentNumber + 1;
END

CREATE TABLE #tempTable (
    RowNumber INT
)
INSERT INTO #tempTable
SELECT ROW_NUMBER() OVER (ORDER BY RowNumber) AS RowNumber
FROM CopyTable

SELECT *
FROM #tempTable
WHERE (RowNumber > 51) AND (RowNumber < 100)

-- podpunkt b
DECLARE @PageSize INT = 10; -- ilosc rekordow na stronie
DECLARE @PageNumber INT = 1; -- Aby wyświetlić drugą stronę, zmień tę wartość na 2


;WITH CTE AS (
    SELECT ROW_NUMBER() OVER (ORDER BY RowNumber) AS RowNumber
    FROM CopyTable
)

SELECT *
FROM CTE
WHERE (RowNumber > (@PageNumber - 1) * @PageSize) AND (RowNumber <= @PageNumber * @PageSize)

------------------------ ZADANIE Z2

SELECT
    sp.Name AS StateProvince,
    a.City,
    COUNT(v.BusinessEntityID) AS NumberOfVendors
FROM
    Purchasing.Vendor v
JOIN
    Purchasing.VendorAddress va ON v.BusinessEntityID = va.BusinessEntityID
JOIN
    Person.Address a ON va.AddressID = a.AddressID
JOIN
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE
    va.AddressType = 'Main Office' -- Filtruje tylko adresy głównej siedziby
GROUP BY
    sp.Name,
    a.City

---------------------- ZADANIE Z3

-- podpunkt a

--DECLARE @PageSize INT = 20;
--DECLARE @PageNumber INT = 5;

;WITH CTE AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY RowNumber) AS RowNumber,
        CASE
            WHEN RowNumber > 51 AND RowNumber < 100 THEN RowNumber
            ELSE NULL
        END AS OnlySelectedRows
    FROM CopyTable
)

SELECT *
FROM CTE
WHERE (RowNumber > (@PageNumber - 1) * @PageSize) AND (RowNumber <= @PageNumber * @PageSize)

--

SELECT
    sp.Name AS StateProvince,
    a.City,
    COUNT(v.BusinessEntityID) AS NumberOfVendors,
    CASE
        WHEN COUNT(v.BusinessEntityID) > 100 THEN 'High'
        WHEN COUNT(v.BusinessEntityID) > 50 THEN 'Medium'
        ELSE 'Low'
    END AS VendorCategory
FROM
    Purchasing.Vendor v
JOIN
    Purchasing.VendorAddress va ON v.BusinessEntityID = va.BusinessEntityID
JOIN
    Person.Address a ON va.AddressID = a.AddressID
JOIN
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE
    va.AddressType = 'Main Office'
GROUP BY
    sp.Name,
    a.City



-- podpunkt b

CREATE TABLE tempdb.dbo.Measurements (
    HOUR INT,
    MINUTE INT,
    CO2Level INT,
    VehicleCount INT
);

DECLARE @i INT = 0;
WHILE @i < 10
BEGIN
    INSERT INTO tempdb.dbo.Measurements (HOUR, MINUTE, CO2Level, VehicleCount)
    VALUES (@i, 0, CAST(RAND()*1000 AS INT), CAST(RAND()*100 AS INT));
    SET @i = @i + 1;
END;

;WITH CO2LevelMinPivot AS (
    SELECT HOUR, MinValue = MIN(CO2Level)
    FROM tempdb.dbo.Measurements
    GROUP BY HOUR
),
CO2LevelMaxPivot AS (
    SELECT HOUR, MaxValue = MAX(CO2Level)
    FROM tempdb.dbo.Measurements
    GROUP BY HOUR
),
CO2LevelSumPivot AS (
    SELECT HOUR, SumValue = SUM(CO2Level)
    FROM tempdb.dbo.Measurements
    GROUP BY HOUR
),
VehicleCountMinPivot AS (
    SELECT HOUR, MinValue = MIN(VehicleCount)
    FROM tempdb.dbo.Measurements
    GROUP BY HOUR
),
VehicleCountMaxPivot AS (
    SELECT HOUR, MaxValue = MAX(VehicleCount)
    FROM tempdb.dbo.Measurements
    GROUP BY HOUR
),
VehicleCountSumPivot AS (
    SELECT HOUR, SumValue = SUM(VehicleCount)
    FROM tempdb.dbo.Measurements
    GROUP BY HOUR
)
SELECT
    COALESCE(CO2LevelMinPivot.HOUR, CO2LevelMaxPivot.HOUR, CO2LevelSumPivot.HOUR) AS HOUR,
    'CO2Level' AS MeasurementType,
    CO2LevelMinPivot.MinValue,
    CO2LevelMaxPivot.MaxValue,
    CO2LevelSumPivot.SumValue
FROM CO2LevelMinPivot
FULL JOIN CO2LevelMaxPivot ON CO2LevelMinPivot.HOUR = CO2LevelMaxPivot.HOUR
FULL JOIN CO2LevelSumPivot ON CO2LevelMinPivot.HOUR = CO2LevelSumPivot.HOUR
UNION ALL
SELECT
    COALESCE(VehicleCountMinPivot.HOUR, VehicleCountMaxPivot.HOUR, VehicleCountSumPivot.HOUR) AS HOUR,
    'VehicleCount' AS MeasurementType,
    VehicleCountMinPivot.MinValue,
    VehicleCountMaxPivot.MaxValue,
    VehicleCountSumPivot.SumValue
FROM VehicleCountMinPivot
FULL JOIN VehicleCountMaxPivot ON VehicleCountMinPivot.HOUR = VehicleCountMaxPivot.HOUR
FULL JOIN VehicleCountSumPivot ON VehicleCountMinPivot.HOUR = VehicleCountSumPivot.HOUR;

DROP TABLE #tempTable
DROP TABLE CopyTable
DROP TABLE tempdb.dbo.Measurements