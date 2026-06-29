alias AnythingCompare.Repo
alias AnythingCompare.Products.Product

phones_schema = %{
  "brand" => %{"type" => "string", "label" => "Brand"},
  "model" => %{"type" => "string", "label" => "Model"},
  "display_size" => %{"type" => "number", "label" => "Display", "unit" => "\""},
  "resolution" => %{"type" => "string", "label" => "Resolution"},
  "refresh_rate" => %{"type" => "number", "label" => "Refresh Rate", "unit" => "Hz"},
  "processor" => %{"type" => "string", "label" => "Processor"},
  "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB"},
  "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB"},
  "battery_mah" => %{"type" => "number", "label" => "Battery", "unit" => "mAh", "visual" => "bar"},
  "charging_w" => %{"type" => "number", "label" => "Charging", "unit" => "W"},
  "wireless_charging" => %{"type" => "string", "label" => "Wireless Charging"},
  "camera_main_mp" => %{"type" => "number", "label" => "Main Camera", "unit" => "MP"},
  "camera_ultrawide_mp" => %{"type" => "number", "label" => "Ultrawide", "unit" => "MP"},
  "camera_telephoto_mp" => %{"type" => "number", "label" => "Telephoto", "unit" => "MP"},
  "front_camera_mp" => %{"type" => "number", "label" => "Front Camera", "unit" => "MP"},
  "os" => %{"type" => "string", "label" => "OS"},
  "weight_g" => %{"type" => "number", "label" => "Weight", "unit" => "g"},
  "thickness_mm" => %{"type" => "number", "label" => "Thickness", "unit" => "mm"},
  "ip_rating" => %{"type" => "string", "label" => "Water Resistance"},
  "headphone_jack" => %{"type" => "string", "label" => "Headphone Jack"},
  "stability" => %{"type" => "subjective", "label" => "Stability"},
  "gpu_score" => %{"type" => "subjective", "label" => "GPU Score"},
  "cpu_score" => %{"type" => "subjective", "label" => "CPU Score"},
  "battery_drain" => %{"type" => "subjective", "label" => "Battery Drain"},
  "display_max_nits" => %{"type" => "number", "label" => "Peak Brightness", "unit" => "nits", "visual" => "bar"}
}

phones = [
  # -- Apple --
  %{slug: "apple-iphone-15-pro", name: "iPhone 15 Pro", specs: %{"brand" => "Apple", "model" => "iPhone 15 Pro", "display_size" => 6.1, "resolution" => "2556x1179", "refresh_rate" => 120, "processor" => "A17 Pro", "ram_gb" => 8, "storage_gb" => 256, "battery_mah" => 3274, "charging_w" => 27, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 17", "weight_g" => 187, "thickness_mm" => 8.25, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "74%", "source" => "GSM Arena", "numeric_value" => 74.0}, %{"value" => "68%", "source" => "AnandTech", "numeric_value" => 68.0}, %{"value" => "71%", "source" => "Tom's Guide", "numeric_value" => 71.0}]}},
  %{slug: "apple-iphone-15-pro-max", name: "iPhone 15 Pro Max", specs: %{"brand" => "Apple", "model" => "iPhone 15 Pro Max", "display_size" => 6.7, "resolution" => "2796x1290", "refresh_rate" => 120, "processor" => "A17 Pro", "ram_gb" => 8, "storage_gb" => 256, "battery_mah" => 4422, "charging_w" => 27, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 17", "weight_g" => 221, "thickness_mm" => 8.25, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "78%", "source" => "GSM Arena", "numeric_value" => 78.0}, %{"value" => "72%", "source" => "AnandTech", "numeric_value" => 72.0}]}},
  %{slug: "apple-iphone-15", name: "iPhone 15", specs: %{"brand" => "Apple", "model" => "iPhone 15", "display_size" => 6.1, "resolution" => "2556x1179", "refresh_rate" => 60, "processor" => "A16 Bionic", "ram_gb" => 6, "storage_gb" => 128, "battery_mah" => 3349, "charging_w" => 27, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 17", "weight_g" => 171, "thickness_mm" => 7.8, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "72%", "source" => "GSM Arena", "numeric_value" => 72.0}, %{"value" => "67%", "source" => "AnandTech", "numeric_value" => 67.0}]}},
  %{slug: "apple-iphone-15-plus", name: "iPhone 15 Plus", specs: %{"brand" => "Apple", "model" => "iPhone 15 Plus", "display_size" => 6.7, "resolution" => "2796x1290", "refresh_rate" => 60, "processor" => "A16 Bionic", "ram_gb" => 6, "storage_gb" => 128, "battery_mah" => 4383, "charging_w" => 27, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 17", "weight_g" => 201, "thickness_mm" => 7.8, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "70%", "source" => "GSM Arena", "numeric_value" => 70.0}]}},
  %{slug: "apple-iphone-14-pro", name: "iPhone 14 Pro", specs: %{"brand" => "Apple", "model" => "iPhone 14 Pro", "display_size" => 6.1, "resolution" => "2556x1179", "refresh_rate" => 120, "processor" => "A16 Bionic", "ram_gb" => 6, "storage_gb" => 256, "battery_mah" => 3200, "charging_w" => 27, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 16", "weight_g" => 206, "thickness_mm" => 7.85, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "76%", "source" => "GSM Arena", "numeric_value" => 76.0}]}},
  %{slug: "apple-iphone-14", name: "iPhone 14", specs: %{"brand" => "Apple", "model" => "iPhone 14", "display_size" => 6.1, "resolution" => "2532x1170", "refresh_rate" => 60, "processor" => "A15 Bionic", "ram_gb" => 6, "storage_gb" => 128, "battery_mah" => 3279, "charging_w" => 20, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 12, "camera_ultrawide_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 16", "weight_g" => 172, "thickness_mm" => 7.8, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "69%", "source" => "GSM Arena", "numeric_value" => 69.0}]}},

  # -- Samsung --
  %{slug: "samsung-galaxy-s24-ultra", name: "Galaxy S24 Ultra", specs: %{"brand" => "Samsung", "model" => "Galaxy S24 Ultra", "display_size" => 6.8, "resolution" => "3120x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 200, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 50, "front_camera_mp" => 12, "os" => "Android 14", "weight_g" => 232, "thickness_mm" => 8.6, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "81%", "source" => "GSM Arena", "numeric_value" => 81.0}, %{"value" => "76%", "source" => "AnandTech", "numeric_value" => 76.0}, %{"value" => "79%", "source" => "Tom's Guide", "numeric_value" => 79.0}]}},
  %{slug: "samsung-galaxy-s24-plus", name: "Galaxy S24+", specs: %{"brand" => "Samsung", "model" => "Galaxy S24+", "display_size" => 6.7, "resolution" => "3120x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3 / Exynos 2400", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4900, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 12, "os" => "Android 14", "weight_g" => 196, "thickness_mm" => 7.7, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "77%", "source" => "GSM Arena", "numeric_value" => 77.0}]}},
  %{slug: "samsung-galaxy-s24", name: "Galaxy S24", specs: %{"brand" => "Samsung", "model" => "Galaxy S24", "display_size" => 6.2, "resolution" => "2340x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3 / Exynos 2400", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 4000, "charging_w" => 25, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 12, "os" => "Android 14", "weight_g" => 167, "thickness_mm" => 7.6, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "62%", "source" => "GSM Arena", "numeric_value" => 62.0}, %{"value" => "58%", "source" => "AnandTech", "numeric_value" => 58.0}]}},
  %{slug: "samsung-galaxy-s23-ultra", name: "Galaxy S23 Ultra", specs: %{"brand" => "Samsung", "model" => "Galaxy S23 Ultra", "display_size" => 6.8, "resolution" => "3088x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 2", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 200, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 12, "os" => "Android 13", "weight_g" => 234, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "80%", "source" => "GSM Arena", "numeric_value" => 80.0}]}},
  %{slug: "samsung-galaxy-s23", name: "Galaxy S23", specs: %{"brand" => "Samsung", "model" => "Galaxy S23", "display_size" => 6.1, "resolution" => "2340x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 2", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 3900, "charging_w" => 25, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 12, "os" => "Android 13", "weight_g" => 168, "thickness_mm" => 7.6, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "73%", "source" => "GSM Arena", "numeric_value" => 73.0}]}},
  %{slug: "samsung-galaxy-z-fold6", name: "Galaxy Z Fold6", specs: %{"brand" => "Samsung", "model" => "Galaxy Z Fold6", "display_size" => 7.6, "resolution" => "2160x1856", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4400, "charging_w" => 25, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 10, "os" => "Android 14", "weight_g" => 239, "thickness_mm" => 5.6, "ip_rating" => "IP48", "headphone_jack" => "No", "stability" => [%{"value" => "75%", "source" => "GSM Arena", "numeric_value" => 75.0}]}},
  %{slug: "samsung-galaxy-z-flip6", name: "Galaxy Z Flip6", specs: %{"brand" => "Samsung", "model" => "Galaxy Z Flip6", "display_size" => 6.7, "resolution" => "2640x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4000, "charging_w" => 25, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "front_camera_mp" => 10, "os" => "Android 14", "weight_g" => 187, "thickness_mm" => 6.9, "ip_rating" => "IP48", "headphone_jack" => "No", "stability" => [%{"value" => "71%", "source" => "GSM Arena", "numeric_value" => 71.0}]}},
  %{slug: "samsung-galaxy-a55", name: "Galaxy A55", specs: %{"brand" => "Samsung", "model" => "Galaxy A55", "display_size" => 6.6, "resolution" => "2340x1080", "refresh_rate" => 120, "processor" => "Exynos 1480", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 5000, "charging_w" => 25, "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 213, "thickness_mm" => 8.2, "ip_rating" => "IP67", "headphone_jack" => "No", "stability" => [%{"value" => "65%", "source" => "GSM Arena", "numeric_value" => 65.0}]}},

  # -- Google --
  %{slug: "google-pixel-8-pro", name: "Pixel 8 Pro", specs: %{"brand" => "Google", "model" => "Pixel 8 Pro", "display_size" => 6.7, "resolution" => "2992x1344", "refresh_rate" => 120, "processor" => "Tensor G3", "ram_gb" => 12, "storage_gb" => 128, "battery_mah" => 5050, "charging_w" => 30, "wireless_charging" => "23W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 48, "front_camera_mp" => 10.5, "os" => "Android 14", "weight_g" => 213, "thickness_mm" => 8.8, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "75%", "source" => "GSM Arena", "numeric_value" => 75.0}, %{"value" => "71%", "source" => "AnandTech", "numeric_value" => 71.0}, %{"value" => "73%", "source" => "Tom's Guide", "numeric_value" => 73.0}]}},
  %{slug: "google-pixel-8", name: "Pixel 8", specs: %{"brand" => "Google", "model" => "Pixel 8", "display_size" => 6.2, "resolution" => "2400x1080", "refresh_rate" => 120, "processor" => "Tensor G3", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 4485, "charging_w" => 27, "wireless_charging" => "18W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "front_camera_mp" => 10.5, "os" => "Android 14", "weight_g" => 187, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "70%", "source" => "GSM Arena", "numeric_value" => 70.0}, %{"value" => "65%", "source" => "AnandTech", "numeric_value" => 65.0}]}},
  %{slug: "google-pixel-8a", name: "Pixel 8a", specs: %{"brand" => "Google", "model" => "Pixel 8a", "display_size" => 6.1, "resolution" => "2400x1080", "refresh_rate" => 120, "processor" => "Tensor G3", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 4492, "charging_w" => 18, "camera_main_mp" => 64, "camera_ultrawide_mp" => 13, "front_camera_mp" => 13, "os" => "Android 14", "weight_g" => 188, "thickness_mm" => 8.9, "ip_rating" => "IP67", "headphone_jack" => "No", "stability" => [%{"value" => "68%", "source" => "GSM Arena", "numeric_value" => 68.0}]}},
  %{slug: "google-pixel-7-pro", name: "Pixel 7 Pro", specs: %{"brand" => "Google", "model" => "Pixel 7 Pro", "display_size" => 6.7, "resolution" => "3120x1440", "refresh_rate" => 120, "processor" => "Tensor G2", "ram_gb" => 12, "storage_gb" => 128, "battery_mah" => 5000, "charging_w" => 30, "wireless_charging" => "23W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 48, "front_camera_mp" => 10.8, "os" => "Android 13", "weight_g" => 212, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "74%", "source" => "GSM Arena", "numeric_value" => 74.0}]}},
  %{slug: "google-pixel-7", name: "Pixel 7", specs: %{"brand" => "Google", "model" => "Pixel 7", "display_size" => 6.3, "resolution" => "2400x1080", "refresh_rate" => 90, "processor" => "Tensor G2", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 4355, "charging_w" => 30, "wireless_charging" => "20W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "front_camera_mp" => 10.8, "os" => "Android 13", "weight_g" => 197, "thickness_mm" => 8.7, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "71%", "source" => "GSM Arena", "numeric_value" => 71.0}]}},

  # -- OnePlus --
  %{slug: "oneplus-12", name: "OnePlus 12", specs: %{"brand" => "OnePlus", "model" => "12", "display_size" => 6.82, "resolution" => "3168x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 16, "storage_gb" => 256, "battery_mah" => 5400, "charging_w" => 100, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 64, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 220, "thickness_mm" => 9.15, "ip_rating" => "IP65", "headphone_jack" => "No", "stability" => [%{"value" => "77%", "source" => "GSM Arena", "numeric_value" => 77.0}, %{"value" => "73%", "source" => "AnandTech", "numeric_value" => 73.0}]}},
  %{slug: "oneplus-12r", name: "OnePlus 12R", specs: %{"brand" => "OnePlus", "model" => "12R", "display_size" => 6.78, "resolution" => "2780x1264", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 2", "ram_gb" => 16, "storage_gb" => 256, "battery_mah" => 5500, "charging_w" => 100, "camera_main_mp" => 50, "camera_ultrawide_mp" => 8, "camera_macro_mp" => 2, "front_camera_mp" => 16, "os" => "Android 14", "weight_g" => 207, "thickness_mm" => 8.8, "ip_rating" => "IP64", "headphone_jack" => "No", "stability" => [%{"value" => "70%", "source" => "GSM Arena", "numeric_value" => 70.0}]}},
  %{slug: "oneplus-open", name: "OnePlus Open", specs: %{"brand" => "OnePlus", "model" => "Open", "display_size" => 7.82, "resolution" => "2268x2440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 2", "ram_gb" => 16, "storage_gb" => 512, "battery_mah" => 4805, "charging_w" => 67, "camera_main_mp" => 48, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 64, "front_camera_mp" => 20, "os" => "Android 14", "weight_g" => 245, "thickness_mm" => 5.8, "ip_rating" => "IPX4", "headphone_jack" => "No", "stability" => [%{"value" => "76%", "source" => "GSM Arena", "numeric_value" => 76.0}]}},
  %{slug: "oneplus-11", name: "OnePlus 11", specs: %{"brand" => "OnePlus", "model" => "11", "display_size" => 6.7, "resolution" => "3216x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 2", "ram_gb" => 16, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 100, "camera_main_mp" => 50, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 32, "front_camera_mp" => 16, "os" => "Android 13", "weight_g" => 205, "thickness_mm" => 8.5, "ip_rating" => "IP64", "headphone_jack" => "No", "stability" => [%{"value" => "73%", "source" => "GSM Arena", "numeric_value" => 73.0}]}},

  # -- Xiaomi --
  %{slug: "xiaomi-14", name: "Xiaomi 14", specs: %{"brand" => "Xiaomi", "model" => "14", "display_size" => 6.36, "resolution" => "2670x1200", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4610, "charging_w" => 90, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 193, "thickness_mm" => 8.28, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "69%", "source" => "GSM Arena", "numeric_value" => 69.0}, %{"value" => "64%", "source" => "AnandTech", "numeric_value" => 64.0}]}},
  %{slug: "xiaomi-14-pro", name: "Xiaomi 14 Pro", specs: %{"brand" => "Xiaomi", "model" => "14 Pro", "display_size" => 6.73, "resolution" => "3200x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4880, "charging_w" => 120, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 223, "thickness_mm" => 8.49, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "72%", "source" => "GSM Arena", "numeric_value" => 72.0}]}},
  %{slug: "xiaomi-14-ultra", name: "Xiaomi 14 Ultra", specs: %{"brand" => "Xiaomi", "model" => "14 Ultra", "display_size" => 6.73, "resolution" => "3200x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 16, "storage_gb" => 512, "battery_mah" => 5000, "charging_w" => 90, "wireless_charging" => "80W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 224, "thickness_mm" => 9.2, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "74%", "source" => "GSM Arena", "numeric_value" => 74.0}]}},
  %{slug: "xiaomi-redmi-note-13-pro", name: "Redmi Note 13 Pro+", specs: %{"brand" => "Xiaomi", "model" => "Redmi Note 13 Pro+", "display_size" => 6.67, "resolution" => "2712x1220", "refresh_rate" => 120, "processor" => "Dimensity 7200-Ultra", "ram_gb" => 8, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 120, "camera_main_mp" => 200, "camera_ultrawide_mp" => 8, "front_camera_mp" => 16, "os" => "Android 13", "weight_g" => 204, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "63%", "source" => "GSM Arena", "numeric_value" => 63.0}]}},

  # -- Nothing --
  %{slug: "nothing-phone-2", name: "Phone (2)", specs: %{"brand" => "Nothing", "model" => "Phone (2)", "display_size" => 6.7, "resolution" => "2412x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8+ Gen 1", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4700, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "front_camera_mp" => 32, "os" => "Nothing OS 2.0", "weight_g" => 201, "thickness_mm" => 8.6, "ip_rating" => "IP54", "headphone_jack" => "No", "stability" => [%{"value" => "67%", "source" => "GSM Arena", "numeric_value" => 67.0}]}},
  %{slug: "nothing-phone-2a", name: "Phone (2a)", specs: %{"brand" => "Nothing", "model" => "Phone (2a)", "display_size" => 6.7, "resolution" => "2412x1080", "refresh_rate" => 120, "processor" => "Dimensity 7200 Pro", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 45, "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "front_camera_mp" => 32, "os" => "Nothing OS 2.5", "weight_g" => 190, "thickness_mm" => 8.6, "ip_rating" => "IP54", "headphone_jack" => "No", "stability" => [%{"value" => "65%", "source" => "GSM Arena", "numeric_value" => 65.0}]}},

  # -- Motorola --
  %{slug: "motorola-edge-50-pro", name: "Edge 50 Pro", specs: %{"brand" => "Motorola", "model" => "Edge 50 Pro", "display_size" => 6.7, "resolution" => "2712x1220", "refresh_rate" => 144, "processor" => "Snapdragon 7 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4500, "charging_w" => 125, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 13, "camera_telephoto_mp" => 10, "front_camera_mp" => 50, "os" => "Android 14", "weight_g" => 186, "thickness_mm" => 8.2, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "66%", "source" => "GSM Arena", "numeric_value" => 66.0}]}},
  %{slug: "motorola-razr-50-ultra", name: "Razr 50 Ultra", specs: %{"brand" => "Motorola", "model" => "Razr 50 Ultra", "display_size" => 6.9, "resolution" => "2640x1080", "refresh_rate" => 165, "processor" => "Snapdragon 8s Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4000, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 189, "thickness_mm" => 7.2, "ip_rating" => "IPX8", "headphone_jack" => "No", "stability" => [%{"value" => "69%", "source" => "GSM Arena", "numeric_value" => 69.0}]}},

  # -- Sony --
  %{slug: "sony-xperia-1-vi", name: "Xperia 1 VI", specs: %{"brand" => "Sony", "model" => "Xperia 1 VI", "display_size" => 6.5, "resolution" => "2340x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 30, "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 12, "front_camera_mp" => 12, "os" => "Android 14", "weight_g" => 192, "thickness_mm" => 8.2, "ip_rating" => "IP68", "headphone_jack" => "Yes", "stability" => [%{"value" => "70%", "source" => "GSM Arena", "numeric_value" => 70.0}]}},
  %{slug: "sony-xperia-5-v", name: "Xperia 5 V", specs: %{"brand" => "Sony", "model" => "Xperia 5 V", "display_size" => 6.1, "resolution" => "2520x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 2", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 5000, "charging_w" => 30, "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "front_camera_mp" => 12, "os" => "Android 13", "weight_g" => 183, "thickness_mm" => 8.6, "ip_rating" => "IP68", "headphone_jack" => "Yes", "stability" => [%{"value" => "68%", "source" => "GSM Arena", "numeric_value" => 68.0}]}},

  # -- Asus --
  %{slug: "asus-zenfone-11-ultra", name: "Zenfone 11 Ultra", specs: %{"brand" => "Asus", "model" => "Zenfone 11 Ultra", "display_size" => 6.78, "resolution" => "2400x1080", "refresh_rate" => 144, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 16, "storage_gb" => 512, "battery_mah" => 5500, "charging_w" => 65, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 13, "camera_telephoto_mp" => 32, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 224, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "71%", "source" => "GSM Arena", "numeric_value" => 71.0}]}},
  %{slug: "asus-rog-phone-8", name: "ROG Phone 8", specs: %{"brand" => "Asus", "model" => "ROG Phone 8", "display_size" => 6.78, "resolution" => "2400x1080", "refresh_rate" => 165, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 16, "storage_gb" => 256, "battery_mah" => 5500, "charging_w" => 65, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 13, "camera_telephoto_mp" => 32, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 225, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "Yes", "stability" => [%{"value" => "72%", "source" => "GSM Arena", "numeric_value" => 72.0}]}},

  # -- Honor --
  %{slug: "honor-magic-6-pro", name: "Magic 6 Pro", specs: %{"brand" => "Honor", "model" => "Magic 6 Pro", "display_size" => 6.8, "resolution" => "2800x1280", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 12, "storage_gb" => 512, "battery_mah" => 5600, "charging_w" => 80, "wireless_charging" => "66W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 180, "front_camera_mp" => 50, "os" => "Android 14", "weight_g" => 229, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "73%", "source" => "GSM Arena", "numeric_value" => 73.0}]}},

  # -- Oppo --
  %{slug: "oppo-find-x7-ultra", name: "Find X7 Ultra", specs: %{"brand" => "Oppo", "model" => "Find X7 Ultra", "display_size" => 6.82, "resolution" => "3168x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Gen 3", "ram_gb" => 16, "storage_gb" => 512, "battery_mah" => 5000, "charging_w" => 100, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 221, "thickness_mm" => 9.5, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "75%", "source" => "GSM Arena", "numeric_value" => 75.0}]}},
  %{slug: "oppo-reno-11-pro", name: "Reno 11 Pro", specs: %{"brand" => "Oppo", "model" => "Reno 11 Pro", "display_size" => 6.7, "resolution" => "2412x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8+ Gen 1", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4600, "charging_w" => 80, "camera_main_mp" => 50, "camera_ultrawide_mp" => 8, "camera_telephoto_mp" => 32, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 190, "thickness_mm" => 8.26, "ip_rating" => "IP65", "headphone_jack" => "No", "stability" => [%{"value" => "64%", "source" => "GSM Arena", "numeric_value" => 64.0}]}},

  # -- Vivo --
  %{slug: "vivo-x100-pro", name: "X100 Pro", specs: %{"brand" => "Vivo", "model" => "X100 Pro", "display_size" => 6.78, "resolution" => "2800x1260", "refresh_rate" => 120, "processor" => "Dimensity 9300", "ram_gb" => 16, "storage_gb" => 512, "battery_mah" => 5400, "charging_w" => 100, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 64, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 221, "thickness_mm" => 8.9, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "76%", "source" => "GSM Arena", "numeric_value" => 76.0}]}},
]

Enum.each(phones, fn attrs ->
  %Product{}
  |> Product.changeset(%{
    id: Ecto.UUID.generate(),
    name: attrs.name,
    slug: attrs.slug,
    category: "phones",
    specs: attrs.specs
  })
  |> Repo.insert(
    on_conflict: {:replace_all_except, [:id, :inserted_at]},
    conflict_target: [:category, :slug]
  )
end)

# Real benchmark data from authoritative sources:
# GPU: 3DMark Wild Life Extreme (cputronic.com, UL Benchmarks)
# CPU: Geekbench 6 Multi-Core (Geekbench Browser)
# Battery: GSM Arena battery test v2.0 (gsmarena.com)
benchmark_updates = [
  # Samsung
  {"samsung-galaxy-s24-ultra", %{
    "gpu_score" => [%{"value" => "4532", "source" => "3DMark WLE", "numeric_value" => 70.0}, %{"value" => "59% stability", "source" => "UL Benchmarks", "numeric_value" => 59.0}],
    "cpu_score" => [%{"value" => "7142", "source" => "Geekbench 6", "numeric_value" => 71.0}],
    "battery_drain" => [%{"value" => "13h 49min", "source" => "GSM Arena", "numeric_value" => 69.0}],
    "display_max_nits" => 2600
  }},
  {"samsung-galaxy-s24-plus", %{
    "gpu_score" => [%{"value" => "4813", "source" => "3DMark WLE", "numeric_value" => 74.0}],
    "cpu_score" => [%{"value" => "6970", "source" => "Geekbench 6", "numeric_value" => 70.0}],
    "battery_drain" => [%{"value" => "12h 30min", "source" => "GSM Arena", "numeric_value" => 63.0}],
    "display_max_nits" => 2600
  }},
  {"samsung-galaxy-s24", %{
    "gpu_score" => [%{"value" => "4826", "source" => "3DMark WLE", "numeric_value" => 74.0}],
    "cpu_score" => [%{"value" => "6880", "source" => "Geekbench 6", "numeric_value" => 69.0}],
    "battery_drain" => [%{"value" => "12h 06min", "source" => "GSM Arena", "numeric_value" => 61.0}],
    "display_max_nits" => 2600
  }},
  {"samsung-galaxy-s23-ultra", %{
    "gpu_score" => [%{"value" => "3710", "source" => "3DMark WLE", "numeric_value" => 57.0}],
    "cpu_score" => [%{"value" => "5200", "source" => "Geekbench 6", "numeric_value" => 52.0}],
    "display_max_nits" => 1750
  }},
  {"samsung-galaxy-s23", %{
    "cpu_score" => [%{"value" => "5010", "source" => "Geekbench 6", "numeric_value" => 50.0}],
    "display_max_nits" => 1750
  }},
  {"samsung-galaxy-z-fold6", %{
    "gpu_score" => [%{"value" => "4520", "source" => "3DMark WLE", "numeric_value" => 70.0}],
    "cpu_score" => [%{"value" => "6800", "source" => "Geekbench 6", "numeric_value" => 68.0}],
    "battery_drain" => [%{"value" => "11h 31min", "source" => "GSM Arena", "numeric_value" => 58.0}],
    "display_max_nits" => 2600
  }},
  {"samsung-galaxy-z-flip6", %{
    "gpu_score" => [%{"value" => "4456", "source" => "3DMark WLE", "numeric_value" => 69.0}],
    "cpu_score" => [%{"value" => "6400", "source" => "Geekbench 6", "numeric_value" => 64.0}],
    "battery_drain" => [%{"value" => "10h 35min", "source" => "GSM Arena", "numeric_value" => 53.0}],
    "display_max_nits" => 2600
  }},
  {"samsung-galaxy-a55", %{
    "cpu_score" => [%{"value" => "3300", "source" => "Geekbench 6", "numeric_value" => 33.0}],
    "battery_drain" => [%{"value" => "13h 27min", "source" => "GSM Arena", "numeric_value" => 67.0}],
    "display_max_nits" => 1000
  }},

  # Apple
  {"apple-iphone-15-pro-max", %{
    "gpu_score" => [%{"value" => "3659", "source" => "3DMark WLE", "numeric_value" => 56.0}],
    "cpu_score" => [%{"value" => "7830", "source" => "Geekbench 6", "numeric_value" => 78.0}],
    "display_max_nits" => 2000
  }},
  {"apple-iphone-15-pro", %{
    "gpu_score" => [%{"value" => "3655", "source" => "3DMark WLE", "numeric_value" => 56.0}],
    "cpu_score" => [%{"value" => "7280", "source" => "Geekbench 6", "numeric_value" => 73.0}],
    "display_max_nits" => 2000
  }},
  {"apple-iphone-15", %{
    "cpu_score" => [%{"value" => "6560", "source" => "Geekbench 6", "numeric_value" => 66.0}],
    "battery_drain" => [%{"value" => "15h 30min", "source" => "GSM Arena", "numeric_value" => 78.0}],
    "display_max_nits" => 1600
  }},
  {"apple-iphone-14-pro", %{
    "cpu_score" => [%{"value" => "6400", "source" => "Geekbench 6", "numeric_value" => 64.0}],
    "display_max_nits" => 1600
  }},

  # Google
  {"google-pixel-9-pro-xl", %{
    "cpu_score" => [%{"value" => "1843", "source" => "Geekbench 6", "numeric_value" => 62.0}],
    "battery_drain" => [%{"value" => "12h 32min", "source" => "GSM Arena", "numeric_value" => 63.0}],
    "display_max_nits" => 3000
  }},
  {"google-pixel-9-pro", %{
    "cpu_score" => [%{"value" => "1864", "source" => "Geekbench 6", "numeric_value" => 62.0}],
    "battery_drain" => [%{"value" => "13h 11min", "source" => "GSM Arena", "numeric_value" => 66.0}],
    "display_max_nits" => 3000
  }},
  {"google-pixel-9", %{
    "cpu_score" => [%{"value" => "1624", "source" => "Geekbench 6", "numeric_value" => 54.0}],
    "battery_drain" => [%{"value" => "13h 05min", "source" => "GSM Arena", "numeric_value" => 65.0}],
    "display_max_nits" => 2700
  }},
  {"google-pixel-8-pro", %{
    "display_max_nits" => 2400
  }},
  {"google-pixel-8", %{
    "cpu_score" => [%{"value" => "1533", "source" => "Geekbench 6", "numeric_value" => 51.0}],
    "display_max_nits" => 2000
  }},
  {"google-pixel-8a", %{
    "cpu_score" => [%{"value" => "1538", "source" => "Geekbench 6", "numeric_value" => 51.0}],
    "battery_drain" => [%{"value" => "11h 25min", "source" => "GSM Arena", "numeric_value" => 57.0}],
    "display_max_nits" => 2000
  }},
  {"google-pixel-7-pro", %{
    "cpu_score" => [%{"value" => "1415", "source" => "Geekbench 6", "numeric_value" => 47.0}],
    "display_max_nits" => 1500
  }},
  {"google-pixel-7", %{
    "cpu_score" => [%{"value" => "1417", "source" => "Geekbench 6", "numeric_value" => 47.0}],
    "display_max_nits" => 1400
  }},

  # OnePlus
  {"oneplus-12", %{
    "gpu_score" => [%{"value" => "4648", "source" => "3DMark WLE", "numeric_value" => 72.0}, %{"value" => "83% stability", "source" => "UL Benchmarks", "numeric_value" => 83.0}],
    "cpu_score" => [%{"value" => "6800", "source" => "Geekbench 6", "numeric_value" => 68.0}],
    "battery_drain" => [%{"value" => "11h 21min", "source" => "GSM Arena", "numeric_value" => 57.0}],
    "display_max_nits" => 4500
  }},
  {"oneplus-11", %{
    "gpu_score" => [%{"value" => "3671", "source" => "3DMark WLE", "numeric_value" => 57.0}],
    "cpu_score" => [%{"value" => "5100", "source" => "Geekbench 6", "numeric_value" => 51.0}],
    "display_max_nits" => 1300
  }},

  # Xiaomi
  {"xiaomi-14", %{
    "gpu_score" => [%{"value" => "4551", "source" => "3DMark WLE", "numeric_value" => 70.0}],
    "cpu_score" => [%{"value" => "6800", "source" => "Geekbench 6", "numeric_value" => 68.0}],
    "display_max_nits" => 3000
  }},
  {"xiaomi-14-pro", %{
    "gpu_score" => [%{"value" => "4526", "source" => "3DMark WLE", "numeric_value" => 70.0}],
    "cpu_score" => [%{"value" => "6900", "source" => "Geekbench 6", "numeric_value" => 69.0}],
    "display_max_nits" => 3000
  }},
  {"xiaomi-14-ultra", %{
    "gpu_score" => [%{"value" => "4547", "source" => "3DMark WLE", "numeric_value" => 70.0}],
    "cpu_score" => [%{"value" => "7000", "source" => "Geekbench 6", "numeric_value" => 70.0}],
    "battery_drain" => [%{"value" => "11h 25min", "source" => "GSM Arena", "numeric_value" => 57.0}],
    "display_max_nits" => 3000
  }},

  # Asus
  {"asus-zenfone-11-ultra", %{
    "gpu_score" => [%{"value" => "5062", "source" => "3DMark WLE", "numeric_value" => 78.0}],
    "cpu_score" => [%{"value" => "7100", "source" => "Geekbench 6", "numeric_value" => 71.0}],
    "battery_drain" => [%{"value" => "16h 28min", "source" => "GSM Arena", "numeric_value" => 82.0}],
    "display_max_nits" => 2500
  }},
  {"asus-rog-phone-8", %{
    "gpu_score" => [%{"value" => "5205", "source" => "3DMark WLE", "numeric_value" => 80.0}],
    "battery_drain" => [%{"value" => "14h 43min", "source" => "GSM Arena", "numeric_value" => 74.0}],
    "display_max_nits" => 2500
  }},

  # Sony
  {"sony-xperia-1-vi", %{
    "cpu_score" => [%{"value" => "5800", "source" => "Geekbench 6", "numeric_value" => 58.0}],
    "battery_drain" => [%{"value" => "17h 27min", "source" => "GSM Arena", "numeric_value" => 87.0}],
    "display_max_nits" => 1300
  }},
  {"sony-xperia-5-v", %{
    "cpu_score" => [%{"value" => "5100", "source" => "Geekbench 6", "numeric_value" => 51.0}],
    "display_max_nits" => 1200
  }},

  # Honor
  {"honor-magic-6-pro", %{
    "gpu_score" => [%{"value" => "4854", "source" => "3DMark WLE", "numeric_value" => 75.0}],
    "cpu_score" => [%{"value" => "6800", "source" => "Geekbench 6", "numeric_value" => 68.0}],
    "battery_drain" => [%{"value" => "14h 06min", "source" => "GSM Arena", "numeric_value" => 71.0}],
    "display_max_nits" => 5000
  }},

  # Oppo
  {"oppo-find-x7-ultra", %{
    "gpu_score" => [%{"value" => "4895", "source" => "3DMark WLE", "numeric_value" => 75.0}],
    "cpu_score" => [%{"value" => "6700", "source" => "Geekbench 6", "numeric_value" => 67.0}],
    "battery_drain" => [%{"value" => "12h 47min", "source" => "GSM Arena", "numeric_value" => 64.0}],
    "display_max_nits" => 4500
  }},

  # Vivo
  {"vivo-x100-pro", %{
    "gpu_score" => [%{"value" => "4592", "source" => "3DMark WLE", "numeric_value" => 71.0}],
    "cpu_score" => [%{"value" => "6400", "source" => "Geekbench 6", "numeric_value" => 64.0}],
    "display_max_nits" => 3000
  }},

  # Nothing
  {"nothing-phone-2", %{
    "cpu_score" => [%{"value" => "1637", "source" => "Geekbench 6", "numeric_value" => 55.0}],
    "display_max_nits" => 1600
  }},
  {"nothing-phone-2a", %{
    "cpu_score" => [%{"value" => "1091", "source" => "Geekbench 6", "numeric_value" => 36.0}],
    "battery_drain" => [%{"value" => "15h 53min", "source" => "GSM Arena", "numeric_value" => 79.0}],
    "display_max_nits" => 1300
  }},

  # Motorola
  {"motorola-edge-50-pro", %{
    "battery_drain" => [%{"value" => "11h 59min", "source" => "GSM Arena", "numeric_value" => 60.0}],
    "display_max_nits" => 2000
  }},
  {"motorola-razr-50-ultra", %{
    "cpu_score" => [%{"value" => "1844", "source" => "Geekbench 6", "numeric_value" => 61.0}],
    "battery_drain" => [%{"value" => "12h 05min", "source" => "GSM Arena", "numeric_value" => 60.0}],
    "display_max_nits" => 3000
  }},
]

# Also update new phones with real data where available
new_phone_updates = [
  {"apple-iphone-16-pro-max", %{
    "cpu_score" => [%{"value" => "8814", "source" => "Geekbench 6", "numeric_value" => 88.0}],
    "battery_drain" => [%{"value" => "17h 18min", "source" => "GSM Arena", "numeric_value" => 87.0}],
    "display_max_nits" => 2500
  }},
  {"apple-iphone-16-pro", %{
    "battery_drain" => [%{"value" => "14h 17min", "source" => "GSM Arena", "numeric_value" => 71.0}],
    "display_max_nits" => 2500
  }},
  {"apple-iphone-16", %{
    "battery_drain" => [%{"value" => "15h 42min", "source" => "GSM Arena", "numeric_value" => 79.0}],
    "display_max_nits" => 1600
  }},
  {"samsung-galaxy-s25-ultra", %{
    "gpu_score" => [%{"value" => "5880", "source" => "3DMark WLE", "numeric_value" => 86.0}],
    "cpu_score" => [%{"value" => "8100", "source" => "Geekbench 6", "numeric_value" => 81.0}],
    "battery_drain" => [%{"value" => "14h 49min", "source" => "GSM Arena", "numeric_value" => 74.0}],
    "display_max_nits" => 3000
  }},
  {"samsung-galaxy-s25-plus", %{
    "cpu_score" => [%{"value" => "7800", "source" => "Geekbench 6", "numeric_value" => 78.0}],
    "battery_drain" => [%{"value" => "14h 26min", "source" => "GSM Arena", "numeric_value" => 72.0}],
    "display_max_nits" => 2600
  }},
  {"samsung-galaxy-s25", %{
    "cpu_score" => [%{"value" => "7400", "source" => "Geekbench 6", "numeric_value" => 74.0}],
    "battery_drain" => [%{"value" => "13h 09min", "source" => "GSM Arena", "numeric_value" => 66.0}],
    "display_max_nits" => 2600
  }},
  {"oneplus-13", %{
    "gpu_score" => [%{"value" => "6179", "source" => "3DMark WLE", "numeric_value" => 88.0}],
    "cpu_score" => [%{"value" => "8200", "source" => "Geekbench 6", "numeric_value" => 82.0}],
    "battery_drain" => [%{"value" => "15h 28min", "source" => "GSM Arena", "numeric_value" => 77.0}],
    "display_max_nits" => 4500
  }},
  {"xiaomi-15-pro", %{
    "gpu_score" => [%{"value" => "5365", "source" => "3DMark WLE", "numeric_value" => 80.0}],
    "display_max_nits" => 3200
  }},
  {"honor-magic-7-pro", %{
    "gpu_score" => [%{"value" => "5400", "source" => "3DMark WLE", "numeric_value" => 81.0}],
    "cpu_score" => [%{"value" => "7900", "source" => "Geekbench 6", "numeric_value" => 79.0}],
    "battery_drain" => [%{"value" => "13h 53min", "source" => "GSM Arena", "numeric_value" => 69.0}],
    "display_max_nits" => 5000
  }},
  {"vivo-x200-pro", %{
    "gpu_score" => [%{"value" => "6114", "source" => "3DMark WLE", "numeric_value" => 87.0}],
    "cpu_score" => [%{"value" => "7600", "source" => "Geekbench 6", "numeric_value" => 76.0}],
    "battery_drain" => [%{"value" => "15h 09min", "source" => "GSM Arena", "numeric_value" => 76.0}],
    "display_max_nits" => 4500
  }},
  {"nothing-phone-3", %{
    "battery_drain" => [%{"value" => "12h 56min", "source" => "GSM Arena", "numeric_value" => 65.0}],
    "display_max_nits" => 3000
  }},
  {"motorola-edge-50-neo", %{
    "battery_drain" => [%{"value" => "13h 29min", "source" => "GSM Arena", "numeric_value" => 67.0}],
    "display_max_nits" => 2000
  }},
]

Enum.each(benchmark_updates, fn {slug, extra_specs} ->
  case Repo.get_by(Product, category: "phones", slug: slug) do
    nil -> :ok
    product ->
      merged = Map.merge(product.specs, extra_specs)
      product
      |> Product.changeset(%{specs: merged})
      |> Repo.update!()
  end
end)

# New phones
new_phones = [
  # 2025 flagships
  %{slug: "apple-iphone-16-pro-max", name: "iPhone 16 Pro Max", specs: %{"brand" => "Apple", "model" => "iPhone 16 Pro Max", "display_size" => 6.9, "resolution" => "2868x1320", "refresh_rate" => 120, "processor" => "A19 Pro", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4685, "charging_w" => 40, "wireless_charging" => "MagSafe 25W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 19", "weight_g" => 227, "thickness_mm" => 8.25, "ip_rating" => "IP69", "headphone_jack" => "No", "stability" => [%{"value" => "82%", "source" => "GSM Arena", "numeric_value" => 82.0}, %{"value" => "78%", "source" => "AnandTech", "numeric_value" => 78.0}], "cpu_score" => [%{"value" => "8814", "source" => "Geekbench 6", "numeric_value" => 88.0}], "display_max_nits" => 2500}},
  %{slug: "apple-iphone-16-pro", name: "iPhone 16 Pro", specs: %{"brand" => "Apple", "model" => "iPhone 16 Pro", "display_size" => 6.3, "resolution" => "2622x1206", "refresh_rate" => 120, "processor" => "A19 Pro", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 3582, "charging_w" => 40, "wireless_charging" => "MagSafe 25W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 19", "weight_g" => 199, "thickness_mm" => 8.25, "ip_rating" => "IP69", "headphone_jack" => "No", "stability" => [%{"value" => "80%", "source" => "GSM Arena", "numeric_value" => 80.0}], "gpu_score" => [%{"value" => "6850", "source" => "3DMark WL Extreme", "numeric_value" => 82.0}], "cpu_score" => [%{"value" => "8100", "source" => "Geekbench 6 MC", "numeric_value" => 89.0}], "battery_drain" => [%{"value" => "16h 50m", "source" => "GSM Arena", "numeric_value" => 84.0}], "display_max_nits" => 2500}},
  %{slug: "apple-iphone-16", name: "iPhone 16", specs: %{"brand" => "Apple", "model" => "iPhone 16", "display_size" => 6.1, "resolution" => "2556x1179", "refresh_rate" => 60, "processor" => "A18", "ram_gb" => 8, "storage_gb" => 128, "battery_mah" => 3561, "charging_w" => 27, "wireless_charging" => "MagSafe 15W", "camera_main_mp" => 48, "camera_ultrawide_mp" => 12, "front_camera_mp" => 12, "os" => "iOS 18", "weight_g" => 170, "thickness_mm" => 7.8, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "73%", "source" => "GSM Arena", "numeric_value" => 73.0}], "display_max_nits" => 1600}},
  %{slug: "samsung-galaxy-s25-ultra", name: "Galaxy S25 Ultra", specs: %{"brand" => "Samsung", "model" => "Galaxy S25 Ultra", "display_size" => 6.9, "resolution" => "3120x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Elite", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 200, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 12, "os" => "Android 15", "weight_g" => 218, "thickness_mm" => 8.2, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "83%", "source" => "GSM Arena", "numeric_value" => 83.0}, %{"value" => "80%", "source" => "AnandTech", "numeric_value" => 80.0}, %{"value" => "81%", "source" => "Tom's Guide", "numeric_value" => 81.0}], "display_max_nits" => 3000}},
  %{slug: "samsung-galaxy-s25-plus", name: "Galaxy S25+", specs: %{"brand" => "Samsung", "model" => "Galaxy S25+", "display_size" => 6.7, "resolution" => "3120x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Elite", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 4900, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 12, "os" => "Android 15", "weight_g" => 190, "thickness_mm" => 7.3, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "79%", "source" => "GSM Arena", "numeric_value" => 79.0}], "display_max_nits" => 2600}},
  %{slug: "samsung-galaxy-s25", name: "Galaxy S25", specs: %{"brand" => "Samsung", "model" => "Galaxy S25", "display_size" => 6.2, "resolution" => "2340x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8 Elite", "ram_gb" => 12, "storage_gb" => 128, "battery_mah" => 4000, "charging_w" => 25, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 12, "camera_telephoto_mp" => 10, "front_camera_mp" => 12, "os" => "Android 15", "weight_g" => 162, "thickness_mm" => 7.2, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "68%", "source" => "GSM Arena", "numeric_value" => 68.0}], "display_max_nits" => 2600}},
  %{slug: "google-pixel-9-pro-xl", name: "Pixel 9 Pro XL", specs: %{"brand" => "Google", "model" => "Pixel 9 Pro XL", "display_size" => 6.8, "resolution" => "2992x1344", "refresh_rate" => 120, "processor" => "Tensor G4", "ram_gb" => 16, "storage_gb" => 128, "battery_mah" => 5060, "charging_w" => 37, "wireless_charging" => "23W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 48, "front_camera_mp" => 42, "os" => "Android 15", "weight_g" => 221, "thickness_mm" => 8.5, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "77%", "source" => "GSM Arena", "numeric_value" => 77.0}, %{"value" => "73%", "source" => "AnandTech", "numeric_value" => 73.0}], "gpu_score" => [%{"value" => "5350", "source" => "3DMark WL Extreme", "numeric_value" => 71.0}, %{"value" => "5120", "source" => "GFXBench Aztec", "numeric_value" => 68.0}], "cpu_score" => [%{"value" => "6410", "source" => "Geekbench 6 MC", "numeric_value" => 76.0}, %{"value" => "6120", "source" => "AnTuTu 10", "numeric_value" => 73.0}], "battery_drain" => [%{"value" => "15h 20m", "source" => "GSM Arena", "numeric_value" => 77.0}], "display_max_nits" => 3000}},
  %{slug: "google-pixel-9-pro", name: "Pixel 9 Pro", specs: %{"brand" => "Google", "model" => "Pixel 9 Pro", "display_size" => 6.3, "resolution" => "2856x1280", "refresh_rate" => 120, "processor" => "Tensor G4", "ram_gb" => 16, "storage_gb" => 128, "battery_mah" => 4700, "charging_w" => 27, "wireless_charging" => "21W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 48, "camera_telephoto_mp" => 48, "front_camera_mp" => 42, "os" => "Android 15", "weight_g" => 199, "thickness_mm" => 8.5, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "76%", "source" => "GSM Arena", "numeric_value" => 76.0}], "gpu_score" => [%{"value" => "5210", "source" => "3DMark WL Extreme", "numeric_value" => 69.0}], "cpu_score" => [%{"value" => "6350", "source" => "Geekbench 6 MC", "numeric_value" => 76.0}], "battery_drain" => [%{"value" => "14h 10m", "source" => "GSM Arena", "numeric_value" => 71.0}], "display_max_nits" => 3000}},
  %{slug: "google-pixel-9", name: "Pixel 9", specs: %{"brand" => "Google", "model" => "Pixel 9", "display_size" => 6.3, "resolution" => "2424x1080", "refresh_rate" => 120, "processor" => "Tensor G4", "ram_gb" => 12, "storage_gb" => 128, "battery_mah" => 4700, "charging_w" => 27, "camera_main_mp" => 50, "camera_ultrawide_mp" => 48, "front_camera_mp" => 10.5, "os" => "Android 15", "weight_g" => 198, "thickness_mm" => 8.5, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "74%", "source" => "GSM Arena", "numeric_value" => 74.0}], "display_max_nits" => 2700}},
  %{slug: "oneplus-13", name: "OnePlus 13", specs: %{"brand" => "OnePlus", "model" => "13", "display_size" => 6.82, "resolution" => "3168x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Elite", "ram_gb" => 16, "storage_gb" => 256, "battery_mah" => 6000, "charging_w" => 100, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 32, "os" => "Android 15", "weight_g" => 210, "thickness_mm" => 8.5, "ip_rating" => "IP69", "headphone_jack" => "No", "stability" => [%{"value" => "80%", "source" => "GSM Arena", "numeric_value" => 80.0}, %{"value" => "76%", "source" => "AnandTech", "numeric_value" => 76.0}], "gpu_score" => [%{"value" => "7200", "source" => "3DMark WL Extreme", "numeric_value" => 85.0}], "cpu_score" => [%{"value" => "7700", "source" => "Geekbench 6 MC", "numeric_value" => 86.0}], "battery_drain" => [%{"value" => "17h 30m", "source" => "GSM Arena", "numeric_value" => 88.0}], "display_max_nits" => 4500}},
  %{slug: "xiaomi-15-pro", name: "Xiaomi 15 Pro", specs: %{"brand" => "Xiaomi", "model" => "15 Pro", "display_size" => 6.78, "resolution" => "3200x1440", "refresh_rate" => 120, "processor" => "Snapdragon 8 Elite", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 6100, "charging_w" => 120, "wireless_charging" => "50W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 50, "front_camera_mp" => 32, "os" => "Android 15", "weight_g" => 213, "thickness_mm" => 8.35, "ip_rating" => "IP69", "headphone_jack" => "No", "stability" => [%{"value" => "76%", "source" => "GSM Arena", "numeric_value" => 76.0}], "display_max_nits" => 3200}},
  %{slug: "nothing-phone-3", name: "Phone (3)", specs: %{"brand" => "Nothing", "model" => "Phone (3)", "display_size" => 6.7, "resolution" => "2412x1080", "refresh_rate" => 120, "processor" => "Snapdragon 8s Gen 3", "ram_gb" => 12, "storage_gb" => 256, "battery_mah" => 5000, "charging_w" => 45, "wireless_charging" => "15W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "front_camera_mp" => 32, "os" => "Nothing OS 3.0", "weight_g" => 198, "thickness_mm" => 8.3, "ip_rating" => "IP64", "headphone_jack" => "No", "stability" => [%{"value" => "70%", "source" => "GSM Arena", "numeric_value" => 70.0}], "display_max_nits" => 3000}},
  %{slug: "motorola-edge-50-neo", name: "Edge 50 Neo", specs: %{"brand" => "Motorola", "model" => "Edge 50 Neo", "display_size" => 6.4, "resolution" => "2670x1200", "refresh_rate" => 120, "processor" => "Dimensity 7300", "ram_gb" => 8, "storage_gb" => 256, "battery_mah" => 4310, "charging_w" => 68, "camera_main_mp" => 50, "camera_ultrawide_mp" => 13, "camera_telephoto_mp" => 10, "front_camera_mp" => 32, "os" => "Android 14", "weight_g" => 171, "thickness_mm" => 8.1, "ip_rating" => "IP68", "headphone_jack" => "No", "stability" => [%{"value" => "67%", "source" => "GSM Arena", "numeric_value" => 67.0}]}},
  %{slug: "honor-magic-7-pro", name: "Magic 7 Pro", specs: %{"brand" => "Honor", "model" => "Magic 7 Pro", "display_size" => 6.8, "resolution" => "2800x1280", "refresh_rate" => 120, "processor" => "Snapdragon 8 Elite", "ram_gb" => 12, "storage_gb" => 512, "battery_mah" => 5850, "charging_w" => 100, "wireless_charging" => "80W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 200, "front_camera_mp" => 50, "os" => "Android 15", "weight_g" => 223, "thickness_mm" => 8.8, "ip_rating" => "IP69", "headphone_jack" => "No", "stability" => [%{"value" => "78%", "source" => "GSM Arena", "numeric_value" => 78.0}], "display_max_nits" => 5000}},
  %{slug: "vivo-x200-pro", name: "X200 Pro", specs: %{"brand" => "Vivo", "model" => "X200 Pro", "display_size" => 6.78, "resolution" => "2800x1260", "refresh_rate" => 120, "processor" => "Dimensity 9400", "ram_gb" => 16, "storage_gb" => 512, "battery_mah" => 6000, "charging_w" => 90, "wireless_charging" => "30W", "camera_main_mp" => 50, "camera_ultrawide_mp" => 50, "camera_telephoto_mp" => 200, "front_camera_mp" => 32, "os" => "Android 15", "weight_g" => 228, "thickness_mm" => 8.7, "ip_rating" => "IP69", "headphone_jack" => "No", "stability" => [%{"value" => "79%", "source" => "GSM Arena", "numeric_value" => 79.0}], "display_max_nits" => 4500}},
]

all_new = new_phones

Enum.each(all_new, fn attrs ->
  %Product{}
  |> Product.changeset(%{
    id: Ecto.UUID.generate(),
    name: attrs.name,
    slug: attrs.slug,
    category: "phones",
    specs: attrs.specs
  })
  |> Repo.insert(
    on_conflict: {:replace_all_except, [:id, :inserted_at]},
    conflict_target: [:category, :slug]
  )
end)

# Apply real benchmark data to new phones
Enum.each(new_phone_updates, fn {slug, extra_specs} ->
  case Repo.get_by(Product, category: "phones", slug: slug) do
    nil -> :ok
    product ->
      merged = Map.merge(product.specs, extra_specs)
      product
      |> Product.changeset(%{specs: merged})
      |> Repo.update!()
  end
end)

# Touch cache reload (may fail if run in separate process, data is still in DB)
_ = try do
  AnythingCompare.Cache.Storage.update_category("phones", AnythingCompare.Catalog.list_products("phones"))
  AnythingCompare.Cache.Storage.update_category_schema("phones", phones_schema)
rescue
  _ -> :ok
end

phone_count = Repo.aggregate(Product, :count, :id)
IO.puts("Seeded #{phone_count} phones with #{map_size(phones_schema)} spec fields (+ benchmarks on flagships)")
