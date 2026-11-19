using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows;
using System.Windows.Media.Imaging;
using ChitaiGorod.Models;
using ChitaiGorod.Services;
using Microsoft.Win32;
using Npgsql;

namespace ChitaiGorod.Views
{
    public partial class ProductEditWindow : Window
    {
        private Product _product;
        private string _selectedSourcePhotoPath;

        public ProductEditWindow(Product product)
        {
            InitializeComponent();
            _product = product;
            LoadLookups();
            FillData();
        }

        private List<LookupItem> GetLookup(string table)
        {
            var list = new List<LookupItem>();
            using (var conn = Db.GetConn())
            using (var cmd = new NpgsqlCommand($"SELECT id, name FROM {table} ORDER BY name", conn))
            using (var r = cmd.ExecuteReader())
                while (r.Read()) list.Add(new LookupItem { Id = r.GetInt32(0), Name = r.GetString(1) });
            return list;
        }

        private void LoadLookups()
        {
            CategoryBox.ItemsSource = GetLookup("category");
            ManufacturerBox.ItemsSource = GetLookup("manufacturer");
            SupplierBox.ItemsSource = GetLookup("supplier");
            UnitBox.ItemsSource = GetLookup("unit");
        }

        private void FillData()
        {
            if (_product == null)
            {
                Title = "Добавление товара — ЧитайГород";
                IdPanel.Visibility = Visibility.Collapsed;
                DiscountBox.Text = "0";
                StockBox.Text = "0";
                PreviewImg.Source = new Product().DisplayImage;

            }
            else
            {
                Title = "Редактирование товара — ЧитайГород";
                IdBox.Text = _product.Id.ToString();
                ArticleBox.Text = _product.Article;
                NameBox.Text = _product.Name;
                CategoryBox.SelectedValue = _product.CategoryId;
                ManufacturerBox.SelectedValue = _product.ManufacturerId;
                SupplierBox.SelectedValue = _product.SupplierId;
                UnitBox.SelectedValue = _product.UnitId;
                PriceBox.Text = _product.Price.ToString("0.##");
                DiscountBox.Text = _product.Discount.ToString("0.##");
                StockBox.Text = _product.StockQuantity.ToString();
                DescBox.Text = _product.Description;
                PreviewImg.Source = _product.DisplayImage;
            }
        }

        private void SelectPhoto_Click(object sender, RoutedEventArgs e)
        {
            var dlg = new OpenFileDialog { Filter = "Изображения (*.jpg;*.jpeg;*.png)|*.jpg;*.jpeg;*.png" };
            if (dlg.ShowDialog() == true)
            {
                _selectedSourcePhotoPath = dlg.FileName;
                PreviewImg.Source = new BitmapImage(new Uri(_selectedSourcePhotoPath));
            }
        }

        private string SaveResizedImage(string sourcePath)
        {
            string fileName = $"{Guid.NewGuid():N}.jpg";
            string relPath = $"Images/{fileName}";
            string destDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Images");
            Directory.CreateDirectory(destDir);
            string destFullPath = Path.Combine(destDir, fileName);

            using (var src = System.Drawing.Image.FromFile(sourcePath))
            using (var bmp = new Bitmap(300, 200))
            using (var g = Graphics.FromImage(bmp))
            {
                g.DrawImage(src, 0, 0, 300, 200);
                bmp.Save(destFullPath, ImageFormat.Jpeg);
            }
            return relPath;
        }


        private void Save_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ArticleBox.Text) || string.IsNullOrWhiteSpace(NameBox.Text) ||
                CategoryBox.SelectedValue == null || ManufacturerBox.SelectedValue == null ||
                SupplierBox.SelectedValue == null || UnitBox.SelectedValue == null)
            {
                MessageBox.Show("Заполните все обязательные поля и выпадающие списки!", "Ошибка ввода", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(PriceBox.Text.Replace('.', ','), out decimal price) || price < 0 ||
                !decimal.TryParse(DiscountBox.Text.Replace('.', ','), out decimal discount) || discount < 0 || discount > 100 ||
                !int.TryParse(StockBox.Text, out int stock) || stock < 0)
            {
                MessageBox.Show("Проверьте корректность чисел: цена >= 0, остаток >= 0, скидка от 0 до 100.", "Ошибка ввода", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            string finalPhotoPath = _product?.PhotoPath;
            if (!string.IsNullOrEmpty(_selectedSourcePhotoPath))
            {
                finalPhotoPath = SaveResizedImage(_selectedSourcePhotoPath);
                if (_product != null && !string.IsNullOrEmpty(_product.PhotoPath) && !_product.PhotoPath.EndsWith("picture.png"))
                {
                    string oldFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, _product.PhotoPath.Replace("/", "\\"));
                    if (File.Exists(oldFile)) { try { File.Delete(oldFile); } catch { } }
                }
            }

            try
            {
                using (var conn = Db.GetConn())
                {
                    string sql = _product == null
                        ? @"INSERT INTO product (article, name, description, category_id, manufacturer_id, supplier_id, unit_id, price, discount, stock_quantity, photo_path)
                            VALUES (@art, @name, @desc, @cat, @man, @sup, @unit, @price, @disc, @stock, @photo)"
                        : @"UPDATE product SET article=@art, name=@name, description=@desc, category_id=@cat, manufacturer_id=@man, 
                            supplier_id=@sup, unit_id=@unit, price=@price, discount=@disc, stock_quantity=@stock, photo_path=@photo WHERE id=@id";

                    using (var cmd = new NpgsqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("art", ArticleBox.Text.Trim());
                        cmd.Parameters.AddWithValue("name", NameBox.Text.Trim());
                        cmd.Parameters.AddWithValue("desc", DescBox.Text.Trim());
                        cmd.Parameters.AddWithValue("cat", (int)CategoryBox.SelectedValue);
                        cmd.Parameters.AddWithValue("man", (int)ManufacturerBox.SelectedValue);
                        cmd.Parameters.AddWithValue("sup", (int)SupplierBox.SelectedValue);
                        cmd.Parameters.AddWithValue("unit", (int)UnitBox.SelectedValue);
                        cmd.Parameters.AddWithValue("price", price);
                        cmd.Parameters.AddWithValue("disc", discount);
                        cmd.Parameters.AddWithValue("stock", stock);
                        cmd.Parameters.AddWithValue("photo", (object)finalPhotoPath ?? DBNull.Value);
                        if (_product != null) cmd.Parameters.AddWithValue("id", _product.Id);
                        cmd.ExecuteNonQuery();
                    }
                }
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка сохранения товара: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Cancel_Click(object sender, RoutedEventArgs e) => Close();
    }
}
