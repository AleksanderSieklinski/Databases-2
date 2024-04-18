-- ZADANIE 1
IF EXISTS (SELECT 1 FROM sys.syslogins WHERE name = 'Lab6user')
BEGIN
    DROP LOGIN Lab6user;
END

GO

CREATE LOGIN Lab6user WITH PASSWORD = 'Passw0rd';

GO

--IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Lab6db')
--BEGIN
--    DROP DATABASE Lab6db;
--END

--GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Lab6user')
BEGIN
    CREATE DATABASE Lab6db;
END

GO

USE Lab6db;

GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Lab6user')
BEGIN
    CREATE USER Lab6user FOR LOGIN Lab6user;
END

GO

EXEC sp_addrolemember 'db_owner', 'Lab6user';

GO

-- ZADANIE 2

USE Lab6db;
GO

IF OBJECT_ID('dbo.CreateTablesAndRelations', 'P') IS NOT NULL
    DROP PROCEDURE dbo.CreateTablesAndRelations;
GO

CREATE PROCEDURE dbo.CreateTablesAndRelations
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'student' AND type = 'U')
    BEGIN
        CREATE TABLE student (
            id INT PRIMARY KEY,
            fname VARCHAR(30),
            lname VARCHAR(30)
        );
    END

    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'wykladowca' AND type = 'U')
    BEGIN
        CREATE TABLE wykladowca (
            id INT PRIMARY KEY,
            fname VARCHAR(30),
            lname VARCHAR(30)
        );
    END

    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'przedmiot' AND type = 'U')
    BEGIN
        CREATE TABLE przedmiot (
            id INT PRIMARY KEY,
            name VARCHAR(50)
        );
    END

    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'grupa' AND type = 'U')
    BEGIN
        CREATE TABLE grupa (
            id_wykl INT,
            id_stud INT,
            id_przed INT,
            PRIMARY KEY (id_wykl, id_stud, id_przed),
            FOREIGN KEY (id_wykl) REFERENCES wykladowca(id),
            FOREIGN KEY (id_stud) REFERENCES student(id),
            FOREIGN KEY (id_przed) REFERENCES przedmiot(id)
        );
    END
END;
GO

EXEC dbo.CreateTablesAndRelations;

SELECT w.fname AS LecturerName, COUNT(s.id) AS StudentCount
        FROM wykladowca w
        JOIN grupa g ON w.id = g.id_wykl
        JOIN student s ON g.id_stud = s.id
        GROUP BY w.fname;

        SELECT p.name AS SubjectName, COUNT(s.id) AS StudentCount
        FROM przedmiot p
        JOIN grupa g ON p.id = g.id_przed
        JOIN student s ON g.id_stud = s.id
        GROUP BY p.name;