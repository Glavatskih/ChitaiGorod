using Npgsql;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChitaiGorod.Services
{
    public static class Db
    {
        public static string ConnString =
            "Host=localhost;Port=5432;Database=chitai_gorod;Username=postgres;Password=9";

        public static NpgsqlConnection GetConn()
        {
            var conn = new NpgsqlConnection(ConnString);
            conn.Open();
            return conn;
        }
    }
}
