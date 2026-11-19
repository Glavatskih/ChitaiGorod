using ChitaiGorod.Services;
using ChitaiGorod.Utils;
using ChitaiGorod.Views;
using Npgsql;
using System;
using System.Windows;
using System.Windows.Controls;

namespace ChitaiGorod
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Login_Click(object sender, RoutedEventArgs e)
        {
            string login = LoginBox.Text.Trim();
            string pass = PasswordBox.Password;

            if (string.IsNullOrEmpty(login) || string.IsNullOrEmpty(pass))
            {
                MessageBox.Show("Введите логин и пароль.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using (var conn = Db.GetConn())
                {
                    string sql = @"SELECT u.id, u.last_name, u.first_name, COALESCE(u.patronymic, ''), u.role_id, r.name 
                                   FROM app_user u JOIN user_role r ON u.role_id = r.id 
                                   WHERE u.login = @l AND u.password = @p";
                    using (var cmd = new NpgsqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("l", login);
                        cmd.Parameters.AddWithValue("p", pass);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                Session.UserId = r.GetInt32(0);
                                Session.FullName = $"{r.GetString(1)} {r.GetString(2)} {r.GetString(3)}".Trim();
                                Session.RoleId = r.GetInt32(4);
                                Session.RoleName = r.GetString(5);

                                new ProductsWindow().Show();
                                this.Close();
                            }
                            else
                            {
                                MessageBox.Show("Неверный логин или пароль!", "Ошибка авторизации", MessageBoxButton.OK, MessageBoxImage.Error);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка подключения к БД: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Guest_Click(object sender, RoutedEventArgs e)
        {
            Session.Clear();
            new ProductsWindow().Show();
            this.Close();
        }
    }
}
