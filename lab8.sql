sp_configure 'clr enabled', 1;
RECONFIGURE;

GO

DROP FUNCTION IF EXISTS dbo.FindEmployeesByAddressTVF;
DROP FUNCTION IF EXISTS dbo.FormatDate;
DROP FUNCTION IF EXISTS dbo.ContainsString;
DROP FUNCTION IF EXISTS dbo.GetSystemTime;
DROP FUNCTION IF EXISTS dbo.GreetUser;

GO
IF EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions')
DROP ASSEMBLY Functions;

GO

DECLARE @hash VARBINARY(64); -- nalezy zakomentowac po raz pierwszy po rekompilacji .dll aby zrestowac hash, wywolac sql, ponownie odkomentowac i uruchomic
SELECT @hash = HASHBYTES('SHA2_512', BulkColumn) FROM OPENROWSET(BULK 'C:\Users\Administrator\source\repos\Lab8\Lab8\Functions.dll', SINGLE_BLOB) AS dll;

EXEC sp_drop_trusted_assembly @hash;
EXEC sp_add_trusted_assembly @hash, N'Functions';

GO

CREATE ASSEMBLY Functions FROM 'C:\Users\Administrator\source\repos\Lab8\Lab8\Functions.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;

GO

USE testCLR;
GO
-- ZADANIE 1
CREATE FUNCTION dbo.ContainsString(@source NVARCHAR(MAX), @toFind NVARCHAR(MAX))
RETURNS BIT
AS EXTERNAL NAME Functions.[Functions].ContainsString;

GO

DROP PROCEDURE IF EXISTS dbo.usp_FindEmployeesByAddress;

GO

CREATE PROCEDURE dbo.usp_FindEmployeesByAddress
    @AddressFragment NVARCHAR(255)
AS
BEGIN
    SELECT E.*
    FROM AdventureWorks2019.HumanResources.Employee E
    INNER JOIN AdventureWorks2019.Person.BusinessEntityAddress BEA ON E.BusinessEntityID = BEA.BusinessEntityID
    INNER JOIN AdventureWorks2019.Person.Address A ON BEA.AddressID = A.AddressID
    WHERE dbo.ContainsString(A.AddressLine1, @AddressFragment) = 1;
END;

GO

EXEC dbo.usp_FindEmployeesByAddress @AddressFragment = 'Napa';

GO
-- ZADANIE 2
DROP FUNCTION IF EXISTS dbo.FormatDate;

GO

CREATE FUNCTION dbo.FormatDate(@date DATETIME, @format NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS EXTERNAL NAME Functions.[Functions].FormatDate;

GO

SELECT dbo.FormatDate(GETDATE(), 'yyyy-MM-dd HH:mm');

GO
-- ZADANIE 3
CREATE FUNCTION dbo.FindEmployeesByAddressTVF(@AddressFragment NVARCHAR(255))
RETURNS TABLE (EmployeeID int, NationalIDNumber nvarchar(15), LoginID nvarchar(256), JobTitle nvarchar(50))
AS EXTERNAL NAME Functions.[Functions].FindEmployeesByAddress;

GO

SELECT * FROM dbo.FindEmployeesByAddressTVF('Napa');