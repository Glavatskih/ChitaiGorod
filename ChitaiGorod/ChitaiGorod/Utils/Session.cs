using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChitaiGorod.Utils
{
    public static class Session
    {
        public static int UserId { get; set; }
        public static string FullName { get; set; } = "Гость";
        public static int RoleId { get; set; } = 0; // 0-Гость, 1-Админ, 2-Менеджер, 3-Клиент
        public static string RoleName { get; set; } = "Гость";

        public static void Clear()
        {
            UserId = 0;
            FullName = "Гость";
            RoleId = 0;
            RoleName = "Гость";
        }
    }
}

