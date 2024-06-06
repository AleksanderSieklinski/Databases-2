-- Zad1
DECLARE @students XML;

SET @students = '<lista></lista>';
SET @students.modify('insert <student><nazwisko>Kowalski</nazwisko><imie>Jakub</imie></student> into (/lista)[1]');
SET @students.modify('insert <student><nazwisko>Wiśniewski</nazwisko><imie>Paweł</imie></student> into (/lista)[1]');
SET @students.modify('insert <student><nazwisko>Nowak</nazwisko><imie>Anna</imie></student> into (/lista)[1]');
SET @students.modify('insert <student><nazwisko>Wójcik</nazwisko><imie>Tomasz</imie></student> into (/lista)[1]');
SET @students.modify('insert <student><nazwisko>Kowalczyk</nazwisko><imie>Robert</imie></student> into (/lista)[1]');
SET @students.modify('insert <grupa>1</grupa> into (/lista/student)[1]');
SET @students.modify('insert <grupa>2</grupa> into (/lista/student)[2]');
SET @students.modify('insert <grupa>1</grupa> into (/lista/student)[3]');
SET @students.modify('insert <grupa>2</grupa> into (/lista/student)[4]');
SET @students.modify('insert <grupa>1</grupa> into (/lista/student)[5]');

SELECT
    Student.value('(nazwisko)[1]', 'NVARCHAR(MAX)') AS Surname,
    Student.value('(imie)[1]', 'NVARCHAR(MAX)') AS Name,
    Student.value('(grupa)[1]', 'INT') AS [Group]
FROM
    @students.nodes('/lista/student') AS T(Student);
-- Zad2
IF OBJECT_ID('AdventureWorks2019.People', 'U') IS NOT NULL
  DROP TABLE AdventureWorks2019.People;

IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'AddressSchema')
DROP XML SCHEMA COLLECTION AddressSchema;

CREATE XML SCHEMA COLLECTION AddressSchema AS '
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="adres">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="miejscowość" type="xs:string"/>
        <xs:element name="kod" type="xs:string"/>
        <xs:element name="ulica" type="xs:string"/>
        <xs:element name="numer_domu" type="xs:string"/>
        <xs:element name="numer_mieszkania" type="xs:string" minOccurs="0"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';

CREATE TABLE People
(
    id INT PRIMARY KEY,
    nazwisko VARCHAR(30),
    imie VARCHAR(20),
    adres XML(AddressSchema)
);

INSERT INTO People (id, nazwisko, imie, adres)
VALUES (1, 'Kowalski', 'Jan', '
<adres>
  <miejscowość>Warszawa</miejscowość>
  <kod>00-001</kod>
  <ulica>Krakowskie Przedmieście</ulica>
  <numer_domu>1</numer_domu>
  <numer_mieszkania>2</numer_mieszkania>
</adres>');

SELECT
    id,
    nazwisko,
    imie,
    adres.value('(/adres/miejscowość)[1]', 'NVARCHAR(MAX)') AS miejscowość,
    adres.value('(/adres/kod)[1]', 'NVARCHAR(MAX)') AS kod,
    adres.value('(/adres/ulica)[1]', 'NVARCHAR(MAX)') AS ulica,
    adres.value('(/adres/numer_domu)[1]', 'NVARCHAR(MAX)') AS numer_domu,
    adres.value('(/adres/numer_mieszkania)[1]', 'NVARCHAR(MAX)') AS numer_mieszkania
FROM People;
-- Zad3
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
SELECT *
FROM Sales.vIndividualCustomer
WHERE Demographics.value('(/ns:IndividualSurvey/ns:TotalChildren)[1]', 'INT') > 1;