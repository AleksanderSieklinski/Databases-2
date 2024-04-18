using System;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;

class Program
{
    private static string connectionString = "Data Source=(local);Initial Catalog=Lab6db;User ID=Lab6user;Password=passw0rd;Connection Timeout=30";

    static void Main(string[] args)
    {
        ExecuteProcedure("CreateTablesAndRelations");

        InsertDataFromCsv(@"C:\Users\Administrator\Documents\students.csv", "student");
        InsertDataFromCsv(@"C:\Users\Administrator\Documents\lecturers.csv", "wykladowca");
        InsertDataFromCsv(@"C:\Users\Administrator\Documents\subjects.csv", "przedmiot");
        InsertDataFromCsv(@"C:\Users\Administrator\Documents\groups.csv", "grupa");

        string query = @"
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
        ";

        ExecuteQuery(query);
    }

    static void ExecuteProcedure(string procedureName)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            connection.Open();

            using (SqlCommand command = new SqlCommand(procedureName, connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.ExecuteNonQuery();
            }
        }
    }

    static void InsertDataFromCsv(string filePath, string tableName)
    {
        var lines = File.ReadAllLines(filePath);

        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            connection.Open();

            foreach (var line in lines.Skip(1))
            {
                var values = line.Split(',');
                string query = $"INSERT INTO {tableName} VALUES (@Value1, @Value2, @Value3)";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@Value1", values[0]);
                    command.Parameters.AddWithValue("@Value2", values[1]);
                    command.Parameters.AddWithValue("@Value3", values[2]);
                    command.ExecuteNonQuery();
                }
            }
        }
    }

    static void ExecuteQuery(string query)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            connection.Open();

            using (SqlCommand command = new SqlCommand(query, connection))
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Console.WriteLine($"Lecturer: {reader["LecturerName"]}, Student Count: {reader["StudentCount"]}");
                    }
                }
            }
        }
    }
}