USE [AdventureWorks2019];
-- Zadanie 1
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'grupa1')
    CREATE ROLE grupa1;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'grupa2')
    CREATE ROLE grupa2;
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester1')
    CREATE LOGIN [WINSERV01\tester1] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english];

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester2')
    CREATE LOGIN [WINSERV01\tester2] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english];

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester3')
    CREATE LOGIN [WINSERV01\tester3] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english];

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester4')
    CREATE LOGIN [WINSERV01\tester4] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english];

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester5')
    CREATE LOGIN [WINSERV01\tester5] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english];

EXEC sp_addrolemember 'grupa1', 'WINSERV01\tester1';
EXEC sp_addrolemember 'grupa1', 'WINSERV01\tester2';
EXEC sp_addrolemember 'grupa1', 'WINSERV01\tester3';
EXEC sp_addrolemember 'grupa2', 'WINSERV01\tester3';
EXEC sp_addrolemember 'grupa2', 'WINSERV01\tester4';
EXEC sp_addrolemember 'grupa2', 'WINSERV01\tester5';

EXEC sp_grantlogin 'WINSERV01\grupa1';
EXEC sp_denylogin 'WINSERV01\grupa2';

IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = 'LogonTrigger')
    DROP TRIGGER LogonTrigger ON ALL SERVER;

GO

CREATE TRIGGER LogonTrigger
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @LoginTime TIME;
    DECLARE @LoginName NVARCHAR(128);
    SET @LoginTime = CAST(GETDATE() AS TIME);
    SET @LoginName = ORIGINAL_LOGIN();

    IF @LoginName = 'WINSERV01\tester1' AND (@LoginTime < '09:00:00' OR @LoginTime > '17:00:00')
    BEGIN
        ROLLBACK;
    END
END;
GO
-- Zadanie 2
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'grupa3')
    CREATE ROLE grupa3;
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester6')
    CREATE LOGIN [WINSERV01\tester6] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'WINSERV01\tester7')
    CREATE LOGIN [WINSERV01\tester7] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];

EXEC sp_addrolemember 'grupa3', 'WINSERV01\tester6';
EXEC sp_addrolemember 'grupa3', 'WINSERV01\tester7';
EXEC sp_addsrvrolemember 'WINSERV01\tester6', 'dbcreator';
EXEC sp_addsrvrolemember 'WINSERV01\tester7', 'serveradmin';
EXEC sp_addrolemember 'db_datawriter', 'WINSERV01\grupa1';
EXEC sp_addrolemember 'db_datawriter', 'WINSERV01\grupa2';
-- Zadanie 3
EXEC sp_addrolemember 'db_datawriter', 'grupa1';
EXEC sp_addrolemember 'db_datawriter', 'grupa2';
EXEC sp_addsrvrolemember 'WINSERV01\tester3', 'sysadmin';
GRANT SELECT ON AdventureWorks2019 TO [WINSERV01\tester2];
GRANT SELECT ON AdventureWorks2019 TO [WINSERV01\tester4];

IF OBJECT_ID('dbo.usp_GetSortedPersons') IS NOT NULL
 DROP PROC dbo.usp_GetSortedPersons;
GO
CREATE PROC dbo.usp_GetSortedPersons
@colname AS sysname = NULL
AS
DECLARE @msg AS NVARCHAR(500);
IF @colname IS NULL
BEGIN
 SET @msg = N'A value must be supplied for parameter @colname.';
 RAISERROR(@msg, 16, 1);
 RETURN;
END
IF @colname
 NOT IN(N'BusinessEntityID', N'LastName', N'PhoneNumber')
 BEGIN
 SET @msg = N'Valid values for @colname are: '
 + N'N''BusinessEntityID'', N''LastName'', N''PhoneNumber''.';
 RAISERROR(@msg, 16, 1);
 RETURN;
END
IF @colname = N'BusinessEntityID'
 SELECT p.BusinessEntityID, LastName, PhoneNumber
 FROM Person.Person p JOIN Person.PersonPhone a ON ( a.BusinessEntityID =
p.BusinessEntityID )
 ORDER BY p.BusinessEntityID;
ELSE IF @colname = N'LastName'
 SELECT p.BusinessEntityID, LastName, PhoneNumber
 FROM Person.Person p JOIN Person.PersonPhone a ON ( a.BusinessEntityID =
p.BusinessEntityID )
 ORDER BY LastName;
ELSE IF @colname = N'PhoneNyumber'
 SELECT p.BusinessEntityID, LastName, PhoneNumber
 FROM Person.Person p JOIN Person.PersonPhone a ON ( a.BusinessEntityID =
p.BusinessEntityID )
 ORDER BY PhoneNumber;