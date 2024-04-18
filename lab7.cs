using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public class Functions
{
    [SqlFunction(DataAccess = DataAccessKind.None, SystemDataAccess = SystemDataAccessKind.None)]
    public static SqlString GreetUser(SqlString userName, SqlString systemVersion, SqlString machineName)
    {
        string greeting = $"Witaj: {userName.Value}, dzisiaj jest: {DateTime.Now}, pracujesz na serwerze {machineName.Value} w systemie {systemVersion.Value}.";
        return new SqlString(greeting);
    }

    [SqlFunction(DataAccess = DataAccessKind.None, SystemDataAccess = SystemDataAccessKind.None)]
    public static SqlDateTime GetSystemTime()
    {
        return new SqlDateTime(DateTime.Now);
    }
}