using System;
using System.IO;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace ChitaiGorod.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Article { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public int ManufacturerId { get; set; }
        public string ManufacturerName { get; set; }
        public int SupplierId { get; set; }
        public string SupplierName { get; set; }
        public int UnitId { get; set; }
        public string UnitName { get; set; }
        public decimal Price { get; set; }
        public decimal Discount { get; set; }
        public int StockQuantity { get; set; }
        public string PhotoPath { get; set; }

        public BitmapImage DisplayImage
        {
            get
            {
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string projectDir = Path.GetFullPath(Path.Combine(baseDir, "..", ".."));

                string cleanName = string.IsNullOrWhiteSpace(PhotoPath)
                    ? "picture.png"
                    : Path.GetFileName(PhotoPath.Trim());

                string[] candidates = new[]
                {
                    Path.Combine(baseDir, "Images", cleanName),
                    Path.Combine(projectDir, "Images", cleanName),
                    Path.Combine(baseDir, "Images", "picture.png"),
                    Path.Combine(projectDir, "Images", "picture.png")
                };

                foreach (string path in candidates)
                {
                    if (File.Exists(path))
                    {
                        try
                        {
                            byte[] bytes = File.ReadAllBytes(path);
                            using (var ms = new MemoryStream(bytes))
                            {
                                var bmp = new BitmapImage();
                                bmp.BeginInit();
                                bmp.CacheOption = BitmapCacheOption.OnLoad;
                                bmp.StreamSource = ms;
                                bmp.EndInit();
                                bmp.Freeze();
                                return bmp;
                            }
                        }
                        catch { }
                    }
                }
                return null;
            }
        }




        public bool HasDiscount => Discount > 0;
        public Visibility OldPriceVisibility => HasDiscount ? Visibility.Visible : Visibility.Collapsed;
        public string OldPriceText => $"{Price:N2} руб.";
        public decimal FinalPrice => Price * (1m - Discount / 100m);
        public string FinalPriceText => $"{FinalPrice:N2} руб.";

        public Brush RowBackground
        {
            get
            {
                if (StockQuantity == 0) return new SolidColorBrush(Color.FromRgb(210, 210, 210));
                if (Discount > 25) return (SolidColorBrush)new BrushConverter().ConvertFrom("#23E1EF");
                return Brushes.White;
            }
        }
    }

    public class LookupItem
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}
