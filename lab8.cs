using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Collections;
using Microsoft.SqlServer.Server;

public class Functions
{
    [SqlFunction(DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read)]
    public static SqlBoolean ContainsString(SqlString source, SqlString toFind)
    {
        return new SqlBoolean(source.Value.Contains(toFind.Value));
    }

    [SqlFunction(DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read)]
    public static SqlString FormatDate(SqlDateTime date, SqlString format)
    {
        return new SqlString(date.Value.ToString(format.Value));
    }

    [SqlFunction(FillRowMethodName = "FillRow", DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read, TableDefinition = "EmployeeID int, NationalIDNumber nvarchar(15), LoginID nvarchar(256), JobTitle nvarchar(50)")]
    public static IEnumerable FindEmployeesByAddress(SqlString addressFragment)
    {
        using (SqlConnection connection = new SqlConnection("context connection=true"))
        {
            connection.Open();

            using (SqlCommand command = new SqlCommand(
                "SELECT E.EmployeeID, E.NationalIDNumber, E.LoginID, E.JobTitle " +
                "FROM HumanResources.Employee E " +
                "INNER JOIN Person.BusinessEntityAddress BEA ON E.BusinessEntityID = BEA.BusinessEntityID " +
                "INNER JOIN Person.Address A ON BEA.AddressID = A.AddressID " +
                "WHERE dbo.ContainsString(A.AddressLine1, @AddressFragment) = 1", connection))
            {
                command.Parameters.Add(new SqlParameter("@AddressFragment", addressFragment.Value));

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        SqlDataRecord record = new SqlDataRecord(new SqlMetaData[] {
                        new SqlMetaData("EmployeeID", SqlDbType.Int),
                        new SqlMetaData("NationalIDNumber", SqlDbType.NVarChar, 15),
                        new SqlMetaData("LoginID", SqlDbType.NVarChar, 256),
                        new SqlMetaData("JobTitle", SqlDbType.NVarChar, 50)
                    });

                        record.SetInt32(0, reader.GetInt32(0));
                        record.SetString(1, reader.GetString(1));
                        record.SetString(2, reader.GetString(2));
                        record.SetString(3, reader.GetString(3));

                        yield return record;
                    }
                }
            }
        }
    }
    public static void FillRow(object row, out SqlInt32 employeeID, out SqlString nationalIDNumber, out SqlString loginID, out SqlString jobTitle)
    {
        SqlDataRecord record = (SqlDataRecord)row;

        employeeID = record.GetInt32(0);
        nationalIDNumber = record.GetString(1);
        loginID = record.GetString(2);
        jobTitle = record.GetString(3);
    }
}