using System;
using System.Data;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;
using System.Transactions;
using System.Data.SqlTypes;

public partial class Functions
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void InsertData(SqlInt32 teacherId, SqlString teacherName, SqlInt32 studentId, SqlString studentName)
    {
        using (TransactionScope scope = new TransactionScope())
        {
            using (SqlConnection connection = new SqlConnection("context connection=true"))
            {
                connection.Open();

                using (SqlCommand command = new SqlCommand())
                {
                    command.Connection = connection;

                    command.CommandText = $"INSERT INTO Teachers (Id, Name) VALUES (@teacherId, @teacherName)";
                    command.Parameters.Add(new SqlParameter("@teacherId", teacherId.Value));
                    command.Parameters.Add(new SqlParameter("@teacherName", teacherName.Value));
                    command.ExecuteNonQuery();

                    command.CommandText = $"INSERT INTO Students (Id, Name) VALUES (@studentId, @studentName)";
                    command.Parameters.Add(new SqlParameter("@studentId", studentId.Value));
                    command.Parameters.Add(new SqlParameter("@studentName", studentName.Value));
                    command.ExecuteNonQuery();

                    command.CommandText = $"INSERT INTO TeacherStudent (TeacherId, StudentId) VALUES (@teacherId, @studentId)"; // Teacher 1 teaches Student 1
                    command.ExecuteNonQuery();
                }
            }

            scope.Complete();
        }
    }
};