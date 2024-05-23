-- Zadanie 1

sp_configure 'clr enabled', 1;
RECONFIGURE;

GO

IF NOT EXISTS (
    SELECT name FROM master.dbo.sysdatabases
    WHERE name = N'testCLR'
)
CREATE DATABASE testCLR;

GO

USE testCLR;

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
SELECT @hash = HASHBYTES('SHA2_512', BulkColumn) FROM OPENROWSET(BULK 'C:\Users\Administrator\source\repos\Lab7\Lab7\Functions.dll', SINGLE_BLOB) AS dll;

EXEC sp_drop_trusted_assembly @hash;
EXEC sp_add_trusted_assembly @hash, N'Functions';

GO

CREATE ASSEMBLY Functions FROM 'C:\Users\Administrator\source\repos\Lab7\Lab7\Functions.dll'
WITH PERMISSION_SET = SAFE;

GO

CREATE FUNCTION GetSystemTime()
RETURNS DATETIME
AS EXTERNAL NAME Functions.[Functions].GetSystemTime;

GO

SELECT dbo.GetSystemTime();

GO

-- Zadanie 2

CREATE FUNCTION GreetUser(@userName NVARCHAR(MAX), @systemVersion NVARCHAR(MAX), @machineName NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS EXTERNAL NAME Functions.[Functions].GreetUser;

GO

SELECT dbo.GreetUser(SUSER_SNAME(), @@VERSION, @@SERVERNAME);

GO

-- Zadanie 3

USE AdventureWorks2019;

GO

DROP PROCEDURE IF EXISTS dbo.usp_FindEmployeesByEmail;

GO

CREATE PROCEDURE dbo.usp_FindEmployeesByEmail
    @EmailFragment NVARCHAR(255)
AS
BEGIN
    SELECT E.*
    FROM HumanResources.Employee E
    INNER JOIN Person.EmailAddress P ON E.BusinessEntityID = P.BusinessEntityID
    WHERE P.EmailAddress LIKE '%' + @EmailFragment + '%';
END;

GO

EXEC dbo.usp_FindEmployeesByEmail @EmailFragment = 'thierry';