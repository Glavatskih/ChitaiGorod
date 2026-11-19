using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Input;
using ChitaiGorod.Models;
using ChitaiGorod.Services;
using ChitaiGorod.Utils;
using Npgsql;

namespace ChitaiGorod.Views
{
    public partial class ProductsWindow : Window
    {
        private List<Product> _allProducts = new List<Product>();
        private bool _isEditOpen = false;

        public ProductsWindow()
        {
            InitializeComponent();
            SetupRoles();
            LoadProducts();
        }

        private void SetupRoles()
        {
            UserFioText.Text = Session.FullName;
            bool isManagerOrAdmin = (Session.RoleId == 1 || Session.RoleId == 2);
            bool isAdmin = (Session.RoleId == 1);

            FilterPanel.Visibility = isManagerOrAdmin ? Visibility.Visible : Visibility.Collapsed;
            OrdersBtn.Visibility = isManagerOrAdmin ? Visibility.Visible : Visibility.Collapsed;
            AddBtn.Visibility = isAdmin ? Visibility.Visible : Visibility.Collapsed;
            DeleteBtn.Visibility = isAdmin ? Visibility.Visible : Visibility.Collapsed;
        }

        public void LoadProducts()
        {
            _allProducts.Clear();
            try
            {
                using (var conn = Db.GetConn())
                {
                    string sql = @"SELECT p.id, p.article, p.name, COALESCE(p.description,''), 
                                          p.category_id, c.name, p.manufacturer_id, m.name, 
                                          p.supplier_id, s.name, p.unit_id, u.name, 
                                          p.price, p.discount, p.stock_quantity, COALESCE(p.photo_path,'')
                                   FROM product p
                                   JOIN category c ON p.category_id = c.id
                                   JOIN manufacturer m ON p.manufacturer_id = m.id
                                   JOIN supplier s ON p.supplier_id = s.id
                                   JOIN unit u ON p.unit_id = u.id
                                   ORDER BY p.id";
                    using (var cmd = new NpgsqlCommand(sql, conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            _allProducts.Add(new Product
                            {
                                Id = r.GetInt32(0),
                                Article = r.GetString(1),
                                Name = r.GetString(2),
                                Description = r.GetString(3),
                                CategoryId = r.GetInt32(4),
                                CategoryName = r.GetString(5),
                                ManufacturerId = r.GetInt32(6),
                                ManufacturerName = r.GetString(7),
                                SupplierId = r.GetInt32(8),
                                SupplierName = r.GetString(9),
                                UnitId = r.GetInt32(10),
                                UnitName = r.GetString(11),
                                Price = r.GetDecimal(12),
                                Discount = r.GetDecimal(13),
                                StockQuantity = r.GetInt32(14),
                                PhotoPath = r.GetString(15)
                            });
                        }
                    }
                }
                ApplyFilters();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки товаров: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ApplyFilters()
        {
            if (_allProducts == null || ProductsList == null) return;
            IEnumerable<Product> query = _allProducts;

            string search = SearchBox?.Text?.Trim().ToLower() ?? "";
            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(p =>
                    p.Name.ToLower().Contains(search) ||
                    p.Article.ToLower().Contains(search) ||
                    p.Description.ToLower().Contains(search) ||
                    p.ManufacturerName.ToLower().Contains(search) ||
                    p.SupplierName.ToLower().Contains(search) ||
                    p.CategoryName.ToLower().Contains(search));
            }

            int discIdx = DiscountFilterBox?.SelectedIndex ?? 0;
            if (discIdx == 1) query = query.Where(p => p.Discount >= 0 && p.Discount <= 12.99m);
            else if (discIdx == 2) query = query.Where(p => p.Discount >= 13m && p.Discount <= 16.99m);
            else if (discIdx == 3) query = query.Where(p => p.Discount >= 17m);

            int sortIdx = SortBox?.SelectedIndex ?? 0;
            if (sortIdx == 1) query = query.OrderBy(p => p.FinalPrice);
            else if (sortIdx == 2) query = query.OrderByDescending(p => p.FinalPrice);
            else if (sortIdx == 3) query = query.OrderBy(p => p.StockQuantity);
            else if (sortIdx == 4) query = query.OrderByDescending(p => p.StockQuantity);

            ProductsList.ItemsSource = query.ToList();
        }

        private void Filter_Changed(object sender, EventArgs e) => ApplyFilters();

        private void Logout_Click(object sender, RoutedEventArgs e)
        {
            Session.Clear();
            new MainWindow().Show();
            this.Close();
        }

        private void Add_Click(object sender, RoutedEventArgs e) => OpenEditWindow(null);

        private void ProductsList_DoubleClick(object sender, MouseButtonEventArgs e)
        {
            if (Session.RoleId == 1 && ProductsList.SelectedItem is Product selected)
                OpenEditWindow(selected);
        }

        private void OpenEditWindow(Product product)
        {
            if (_isEditOpen) return;
            _isEditOpen = true;
            var win = new ProductEditWindow(product);
            win.Closed += (s, args) => { _isEditOpen = false; LoadProducts(); };
            win.Show();
        }

        private void Delete_Click(object sender, RoutedEventArgs e)
        {
            if (!(ProductsList.SelectedItem is Product selected))
            {
                MessageBox.Show("Выберите товар для удаления.", "Внимание", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            if (MessageBox.Show($"Удалить товар «{selected.Name}»?", "Подтверждение", MessageBoxButton.YesNo, MessageBoxImage.Question) != MessageBoxResult.Yes)
                return;

            try
            {
                using (var conn = Db.GetConn())
                using (var cmd = new NpgsqlCommand("DELETE FROM product WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("id", selected.Id);
                    cmd.ExecuteNonQuery();
                }

                if (!string.IsNullOrEmpty(selected.PhotoPath) && !selected.PhotoPath.EndsWith("picture.png"))
                {
                    string fullPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, selected.PhotoPath.Replace("/", "\\"));
                    if (File.Exists(fullPath)) File.Delete(fullPath);
                }

                LoadProducts();
            }
            catch (PostgresException ex) when (ex.SqlState == "23503")
            {
                MessageBox.Show("Нельзя удалить товар, который присутствует в заказе!", "Ошибка удаления", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при удалении: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Orders_Click(object sender, RoutedEventArgs e)
        {
            new OrdersWindow().ShowDialog();
        }
    }
}
