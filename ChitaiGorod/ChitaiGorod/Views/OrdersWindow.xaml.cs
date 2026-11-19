using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Input;
using ChitaiGorod.Services;
using ChitaiGorod.Utils;
using Npgsql;

namespace ChitaiGorod.Views
{
    public class OrderViewModel
    {
        public int Id { get; set; }
        public string ArticlesText { get; set; }
        public int StatusId { get; set; }
        public string StatusName { get; set; }
        public int PickupPointId { get; set; }
        public string PickupAddress { get; set; }
        public DateTime OrderDate { get; set; }
        public DateTime DeliveryDate { get; set; }
        public string PickupCode { get; set; }
        public string OrderDateText => OrderDate.ToString("dd.MM.yyyy");
        public string DeliveryDateText => DeliveryDate.ToString("dd.MM.yyyy");
    }

    public partial class OrdersWindow : Window
    {
        public OrdersWindow()
        {
            InitializeComponent();
            AdminOrderPanel.Visibility = (Session.RoleId == 1) ? Visibility.Visible : Visibility.Collapsed;
            LoadOrders();
        }

        public void LoadOrders()
        {
            var list = new List<OrderViewModel>();
            try
            {
                using (var conn = Db.GetConn())
                {
                    string sql = @"SELECT o.id, o.status_id, s.name, o.pickup_point_id, 
                      pp.address,
                      o.order_date, o.delivery_date, o.receive_code::text,
                      COALESCE((SELECT string_agg(p.article || ', ' || oi.quantity, ', ') 
                                FROM order_item oi JOIN product p ON oi.product_id = p.id WHERE oi.order_id = o.id), 'Без позиций')
               FROM customer_order o
               JOIN order_status s ON o.status_id = s.id
               JOIN pickup_point pp ON o.pickup_point_id = pp.id
               ORDER BY o.id";

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            list.Add(new OrderViewModel
                            {
                                Id = r.GetInt32(0),
                                StatusId = r.GetInt32(1),
                                StatusName = r.GetString(2),
                                PickupPointId = r.GetInt32(3),
                                PickupAddress = r.GetString(4),
                                OrderDate = r.GetDateTime(5),
                                DeliveryDate = r.GetDateTime(6),
                                PickupCode = r.GetString(7),
                                ArticlesText = r.GetString(8)
                            });
                        }
                    }
                }
                OrdersList.ItemsSource = list;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки заказов: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Back_Click(object sender, RoutedEventArgs e) => Close();

        private void AddOrder_Click(object sender, RoutedEventArgs e)
        {
            new OrderEditWindow(null).ShowDialog();
            LoadOrders();
        }

        private void OrdersList_DoubleClick(object sender, MouseButtonEventArgs e)
        {
            if (Session.RoleId == 1 && OrdersList.SelectedItem is OrderViewModel selected)
            {
                new OrderEditWindow(selected).ShowDialog();
                LoadOrders();
            }
        }

        private void DeleteOrder_Click(object sender, RoutedEventArgs e)
        {
            if (!(OrdersList.SelectedItem is OrderViewModel selected)) return;
            if (MessageBox.Show($"Удалить заказ №{selected.Id}?", "Подтверждение", MessageBoxButton.YesNo, MessageBoxImage.Question) != MessageBoxResult.Yes) return;

            using (var conn = Db.GetConn())
            using (var cmd = new NpgsqlCommand("DELETE FROM customer_order WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("id", selected.Id);
                cmd.ExecuteNonQuery();
            }
            LoadOrders();
        }
    }
}
