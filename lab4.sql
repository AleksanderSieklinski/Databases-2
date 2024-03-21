USE AdventureWorks2019;

GO

CREATE PROCEDURE dbo.usp_task1
AS
BEGIN
    DECLARE @FirstName NVARCHAR(50), @LastName NVARCHAR(50), @PhoneNumber NVARCHAR(50), @EmailAddress NVARCHAR(50)
    DECLARE person_cursor CURSOR FOR
    SELECT TOP 50 p.FirstName, p.LastName, pp.PhoneNumber, e.EmailAddress
    FROM Person.Person AS p
    JOIN Person.PersonPhone AS pp ON p.BusinessEntityID = pp.BusinessEntityID
    JOIN Person.EmailAddress AS e ON p.BusinessEntityID = e.BusinessEntityID
    OPEN person_cursor
    FETCH NEXT FROM person_cursor INTO @FirstName, @LastName, @PhoneNumber, @EmailAddress
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Imie: ' + @FirstName + ', Nazwisko: ' + @LastName
        PRINT '- Telefon: ' + @PhoneNumber
        PRINT '- Email: ' + @EmailAddress
        FETCH NEXT FROM person_cursor INTO @FirstName, @LastName, @PhoneNumber, @EmailAddress
    END
    CLOSE person_cursor
    DEALLOCATE person_cursor
END

GO

EXEC dbo.usp_task1;

GO

DROP PROCEDURE dbo.usp_task1;

GO

CREATE TABLE dbo.PersonLog
(
    LogID INT IDENTITY PRIMARY KEY,
    PersonID INT,
    OldFirstName NVARCHAR(50),
    NewFirstName NVARCHAR(50),
    OldLastName NVARCHAR(50),
    NewLastName NVARCHAR(50),
    UpdateDate DATETIME DEFAULT GETDATE()
)

GO

CREATE TRIGGER trg_Person_Update
ON Person.Person
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.PersonLog (PersonID, OldFirstName, NewFirstName, OldLastName, NewLastName)
    SELECT
        d.BusinessEntityID,
        d.FirstName,
        i.FirstName,
        d.LastName,
        i.LastName
    FROM
        deleted d
    INNER JOIN
        inserted i ON d.BusinessEntityID = i.BusinessEntityID
END

GO

SELECT * FROM dbo.PersonLog;

GO

UPDATE Person.Person SET FirstName = 'Janusz' WHERE BusinessEntityID = 1;

GO

SELECT * FROM dbo.PersonLog;

GO

UPDATE Person.Person SET FirstName = 'Ken' WHERE BusinessEntityID = 1; -- zmiana imienia na oryginalne

GO

DROP TABLE dbo.PersonLog;

GO

DROP TRIGGER Person.trg_Person_Update;

GO

CREATE PROCEDURE dbo.usp_CheckProductStock
    @ProductID INT
AS
BEGIN
    DECLARE @Quantity INT
    SELECT @Quantity = SUM(Quantity) FROM Production.ProductInventory WHERE ProductID = @ProductID
    IF @Quantity IS NULL OR @Quantity = 0
    BEGIN
        RAISERROR (N'Produkt o ID %d nie jest dostępny w magazynie.', 16, 1, @ProductID)
    END
    SELECT @Quantity AS Quantity, p.Name AS ProductName
    FROM Production.Product AS p
    WHERE p.ProductID = @ProductID
END

GO

EXEC dbo.usp_CheckProductStock @ProductID = 5; -- nie ma w magazynie

GO

EXEC dbo.usp_CheckProductStock @ProductID = 3; -- jest w magazynie

GO

DROP PROCEDURE dbo.usp_CheckProductStock;