-- Zad1
IF OBJECT_ID('test1', 'U') IS NOT NULL
  DROP TABLE test1;

GO

CREATE TABLE test1
(
    col1 INT,
    col2 NVARCHAR(MAX),
    col3 NVARCHAR(MAX)
);

GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'log_table')
CREATE TABLE log_table
(
    log_date DATETIME,
    inserted_data NVARCHAR(MAX),
    username NVARCHAR(50)
);

GO

CREATE TRIGGER trg_after_insert_test1
ON test1
AFTER INSERT
AS
BEGIN
    DECLARE @inserted_data NVARCHAR(MAX);
    DECLARE @username NVARCHAR(50);
    SELECT @inserted_data = CONCAT_WS(', ', col1, col2, col3) FROM inserted;
    SELECT @username = SYSTEM_USER;
    INSERT INTO log_table (log_date, inserted_data, username)
    VALUES (GETDATE(), @inserted_data, @username);
END;

GO

INSERT INTO test1 (col1, col2, col3) VALUES (1, 'Test data 1', 'More test data 1');
SELECT * FROM log_table;
INSERT INTO test1 (col1, col2, col3) VALUES (2, 'Test data 2', 'More test data 2');
SELECT * FROM log_table;

-- Zad2
IF OBJECT_ID('TeacherStudent', 'U') IS NOT NULL
  DROP TABLE TeacherStudent;

IF OBJECT_ID('Teachers', 'U') IS NOT NULL
  DROP TABLE Teachers;

IF OBJECT_ID('Students', 'U') IS NOT NULL
  DROP TABLE Students;

CREATE TABLE Teachers
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(MAX)
);

CREATE TABLE Students
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(MAX)
);

CREATE TABLE TeacherStudent
(
    TeacherId INT,
    StudentId INT,
    PRIMARY KEY (TeacherId, StudentId),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id)
);

GO

--csc /target:library /out:"C:\Users\Administrator\source\repos\Lab10\Lab10\Functions.dll" "C:\Users\Administrator\source\repos\Lab10\Lab10\Program.cs"

sp_configure 'clr enabled', 1;
RECONFIGURE;

GO

DROP PROCEDURE IF EXISTS InsertData;

GO

IF EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions')
DROP ASSEMBLY Functions;

GO

DECLARE @hash VARBINARY(64); -- nalezy zakomentowac po raz pierwszy po rekompilacji .dll aby zrestowac hash, wywolac sql, ponownie odkomentowac i uruchomic
SELECT @hash = HASHBYTES('SHA2_512', BulkColumn) FROM OPENROWSET(BULK 'C:\Users\Administrator\source\repos\Lab10\Lab10\Functions.dll', SINGLE_BLOB) AS dll;
EXEC sp_drop_trusted_assembly @hash;
EXEC sp_add_trusted_assembly @hash, N'Functions';

GO

CREATE ASSEMBLY Functions FROM 'C:\Users\Administrator\source\repos\Lab10\Lab10\Functions.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;

GO

CREATE PROCEDURE InsertData
    @teacherId INT,
    @teacherName NVARCHAR(MAX),
    @studentId INT,
    @studentName NVARCHAR(MAX)
AS EXTERNAL NAME Functions.[Functions].InsertData;

GO

EXEC InsertData 3, 'Teacher 3', 3, 'Student 3';

GO

SELECT * FROM Teachers;
SELECT * FROM Students;
SELECT * FROM TeacherStudent;