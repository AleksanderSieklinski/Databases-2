-- Zadanie 1
CREATE FUNCTION dbo.GetPersonDetails(@BusinessEntityID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX);

    SELECT @Result = ISNULL(p.LastName, '') + ';' +
                     ISNULL(p.FirstName, '') + ';' +
                     ISNULL(e.EmailAddress, '') + ';' +
                     ISNULL(a.AddressLine1, '') + ' ' + ISNULL(a.AddressLine2, '') + ' ' + ISNULL(a.City, '') + ' ' + ISNULL(a.PostalCode, '')
    FROM Person.Person p
    JOIN Person.BusinessEntity bec ON p.BusinessEntityID = bec.BusinessEntityID
    JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
    JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
    JOIN Person.Address a ON bea.AddressID = a.AddressID
    WHERE p.BusinessEntityID = @BusinessEntityID;

    RETURN @Result;
END;
SELECT dbo.GetPersonDetails(1);
DROP FUNCTION dbo.GetPersonDetails;
-- Zadanie 2
CREATE FUNCTION dbo.GetPersonSubset(@StartRow INT, @EndRow INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        InnerQuery.RowNum,
        InnerQuery.LastName,
        InnerQuery.FirstName,
        InnerQuery.EmailAddress,
        InnerQuery.AddressLine1 + ' ' + InnerQuery.AddressLine2 + ' ' + InnerQuery.City + ' ' + InnerQuery.PostalCode AS Address
    FROM
        (SELECT
            ROW_NUMBER() OVER (ORDER BY p.LastName, p.FirstName, a.AddressLine1) AS RowNum,
            p.LastName,
            p.FirstName,
            e.EmailAddress,
            a.AddressLine1,
            a.AddressLine2,
            a.City,
            a.PostalCode
        FROM
            Person.Person p
        JOIN
            Person.BusinessEntity bec ON p.BusinessEntityID = bec.BusinessEntityID
        JOIN
            Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
        JOIN
            Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN
            Person.Address a ON bea.AddressID = a.AddressID) AS InnerQuery
    WHERE
        InnerQuery.RowNum BETWEEN @StartRow AND @EndRow
);
SELECT * FROM dbo.GetPersonSubset(1, 20);
DROP FUNCTION dbo.GetPersonSubset;
-- Zadanie 3
CREATE FUNCTION dbo.GetOrdersForCustomer(@CustomerName NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
    FROM Sales.Customer c
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    WHERE p.FirstName + ' ' + p.LastName = @CustomerName
);
SELECT * FROM dbo.GetOrdersForCustomer('Linda Mitchell');
DROP FUNCTION dbo.GetOrdersForCustomer;