using System;
using System.Collections.Generic;
using System.Windows;
using ChitaiGorod.Models;
using ChitaiGorod.Services;
using ChitaiGorod.Utils;
using Npgsql;

namespace ChitaiGorod.Views
{
    public partial class OrderEditWindow : Window
    {
        private OrderViewModel _order;

        public OrderEditWindow(OrderViewModel order)
        {
            InitializeComponent();
            _order = order;
            LoadLists();

            if (_order == null)
            {
                OrderDatePicker.SelectedDate = DateTime.Today;
                DeliveryDatePicker.SelectedDate = DateTime.Today.AddDays(3);
                CodeBox.Text = new Random().Next(100, 999).ToString();
            }
            else
            {
                ProductLabel.Visibility = Visibility.Collapsed;
                ProductBox.Visibility = Visibility.Collapsed;
                StatusBox.SelectedValue = _order.StatusId;
                PickupBox.SelectedValue = _order.PickupPointId;
                OrderDatePicker.SelectedDate = _order.OrderDate;
                DeliveryDatePicker.SelectedDate = _order.DeliveryDate;
                CodeBox.Text = _order.PickupCode;
            }
        }

        private void LoadLists()
        {
            var statuses = new List<LookupItem>();
            var pickups = new List<LookupItem>();
            var products = new List<LookupItem>();

            using (var conn = Db.GetConn())
            {
                using (var cmd = new NpgsqlCommand("SELECT id, name FROM order_status ORDER BY id", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) statuses.Add(new LookupItem { Id = r.GetInt32(0), Name = r.GetString(1) });

                using (var cmd = new NpgsqlCommand("SELECT id, address FROM pickup_point ORDER BY id", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) pickups.Add(new LookupItem { Id = r.GetInt32(0), Name = r.GetString(1) });

                using (var cmd = new NpgsqlCommand("SELECT id, article || ' — ' || name FROM product ORDER BY id", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) products.Add(new LookupItem { Id = r.GetInt32(0), Name = r.GetString(1) });
            }

            StatusBox.ItemsSource = statuses;
            PickupBox.ItemsSource = pickups;
            ProductBox.ItemsSource = products;
            if (products.Count > 0) ProductBox.SelectedIndex = 0;
        }

        private void Save_Click(object sender, RoutedEventArgs e)
        {
            if (StatusBox.SelectedValue == null || PickupBox.SelectedValue == null ||
                OrderDatePicker.SelectedDate == null || DeliveryDatePicker.SelectedDate == null ||
                string.IsNullOrWhiteSpace(CodeBox.Text))
            {
                MessageBox.Show("Заполните все поля заказа!", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (DeliveryDatePicker.SelectedDate < OrderDatePicker.SelectedDate)
            {
                MessageBox.Show("Дата доставки не может быть раньше даты заказа!", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            if (!int.TryParse(CodeBox.Text.Trim(), out int receiveCode))
            {
                MessageBox.Show("Код получения должен быть числом!", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                using (var conn = Db.GetConn())
                {
                    if (_order == null)
                    {
                        int userId = Session.UserId > 0 ? Session.UserId : 1;
                        string sql = @"INSERT INTO customer_order (order_date, delivery_date, pickup_point_id, user_id, receive_code, status_id)
                               VALUES (@od, @dd, @pp, @uid, @code, @st) RETURNING id";
                        int newId;
                        using (var cmd = new NpgsqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("od", OrderDatePicker.SelectedDate.Value);
                            cmd.Parameters.AddWithValue("dd", DeliveryDatePicker.SelectedDate.Value);
                            cmd.Parameters.AddWithValue("pp", (int)PickupBox.SelectedValue);
                            cmd.Parameters.AddWithValue("uid", userId);
                            cmd.Parameters.AddWithValue("code", receiveCode);
                            cmd.Parameters.AddWithValue("st", (int)StatusBox.SelectedValue);
                            newId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                        if (ProductBox.SelectedValue != null)
                        {
                            using (var cmdItem = new NpgsqlCommand("INSERT INTO order_item (order_id, product_id, quantity) VALUES (@oid, @pid, 1)", conn))
                            {
                                cmdItem.Parameters.AddWithValue("oid", newId);
                                cmdItem.Parameters.AddWithValue("pid", (int)ProductBox.SelectedValue);
                                cmdItem.ExecuteNonQuery();
                            }
                        }
                    }
                    else
                    {
                        string sql = @"UPDATE customer_order SET order_date=@od, delivery_date=@dd, pickup_point_id=@pp, receive_code=@code, status_id=@st WHERE id=@id";
                        using (var cmd = new NpgsqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("od", OrderDatePicker.SelectedDate.Value);
                            cmd.Parameters.AddWithValue("dd", DeliveryDatePicker.SelectedDate.Value);
                            cmd.Parameters.AddWithValue("pp", (int)PickupBox.SelectedValue);
                            cmd.Parameters.AddWithValue("code", receiveCode);
                            cmd.Parameters.AddWithValue("st", (int)StatusBox.SelectedValue);
                            cmd.Parameters.AddWithValue("id", _order.Id);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка сохранения заказа: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }


        private void Cancel_Click(object sender, RoutedEventArgs e) => Close();
    }
}
