alias AnythingCompare.Repo
alias AnythingCompare.Products.Product

phones = [
  %{
    slug: "apple-iphone-15-pro",
    name: "iPhone 15 Pro",
    category: "phones",
    specs: %{
      "brand" => "Apple",
      "model" => "iPhone 15 Pro",
      "battery_mah" => 3274,
      "display_size" => 6.1,
      "ram_gb" => 8,
      "storage_gb" => 256,
      "os" => "iOS 17",
      "stability" => [
        %{"value" => "74%", "source" => "GSM Arena", "numeric_value" => 74.0},
        %{"value" => "68%", "source" => "AnandTech", "numeric_value" => 68.0},
        %{"value" => "71%", "source" => "Tom's Guide", "numeric_value" => 71.0}
      ]
    }
  },
  %{
    slug: "apple-iphone-15-pro-max",
    name: "iPhone 15 Pro Max",
    category: "phones",
    specs: %{
      "brand" => "Apple",
      "model" => "iPhone 15 Pro Max",
      "battery_mah" => 4422,
      "display_size" => 6.7,
      "ram_gb" => 8,
      "storage_gb" => 256,
      "os" => "iOS 17",
      "stability" => [
        %{"value" => "78%", "source" => "GSM Arena", "numeric_value" => 78.0},
        %{"value" => "72%", "source" => "AnandTech", "numeric_value" => 72.0}
      ]
    }
  },
  %{
    slug: "samsung-galaxy-s24",
    name: "Galaxy S24",
    category: "phones",
    specs: %{
      "brand" => "Samsung",
      "model" => "Galaxy S24",
      "battery_mah" => 4000,
      "display_size" => 6.2,
      "ram_gb" => 8,
      "storage_gb" => 128,
      "os" => "Android 14",
      "stability" => [
        %{"value" => "62%", "source" => "GSM Arena", "numeric_value" => 62.0},
        %{"value" => "58%", "source" => "AnandTech", "numeric_value" => 58.0}
      ]
    }
  },
  %{
    slug: "samsung-galaxy-s24-ultra",
    name: "Galaxy S24 Ultra",
    category: "phones",
    specs: %{
      "brand" => "Samsung",
      "model" => "Galaxy S24 Ultra",
      "battery_mah" => 5000,
      "display_size" => 6.8,
      "ram_gb" => 12,
      "storage_gb" => 256,
      "os" => "Android 14",
      "stability" => [
        %{"value" => "81%", "source" => "GSM Arena", "numeric_value" => 81.0},
        %{"value" => "76%", "source" => "AnandTech", "numeric_value" => 76.0},
        %{"value" => "79%", "source" => "Tom's Guide", "numeric_value" => 79.0}
      ]
    }
  },
  %{
    slug: "google-pixel-8",
    name: "Pixel 8",
    category: "phones",
    specs: %{
      "brand" => "Google",
      "model" => "Pixel 8",
      "battery_mah" => 4485,
      "display_size" => 6.2,
      "ram_gb" => 8,
      "storage_gb" => 128,
      "os" => "Android 14",
      "stability" => [
        %{"value" => "70%", "source" => "GSM Arena", "numeric_value" => 70.0},
        %{"value" => "65%", "source" => "AnandTech", "numeric_value" => 65.0}
      ]
    }
  },
  %{
    slug: "google-pixel-8-pro",
    name: "Pixel 8 Pro",
    category: "phones",
    specs: %{
      "brand" => "Google",
      "model" => "Pixel 8 Pro",
      "battery_mah" => 5050,
      "display_size" => 6.7,
      "ram_gb" => 12,
      "storage_gb" => 128,
      "os" => "Android 14",
      "stability" => [
        %{"value" => "75%", "source" => "GSM Arena", "numeric_value" => 75.0},
        %{"value" => "71%", "source" => "AnandTech", "numeric_value" => 71.0},
        %{"value" => "73%", "source" => "Tom's Guide", "numeric_value" => 73.0}
      ]
    }
  },
  %{
    slug: "oneplus-12",
    name: "OnePlus 12",
    category: "phones",
    specs: %{
      "brand" => "OnePlus",
      "model" => "12",
      "battery_mah" => 5400,
      "display_size" => 6.82,
      "ram_gb" => 16,
      "storage_gb" => 256,
      "os" => "Android 14",
      "stability" => [
        %{"value" => "77%", "source" => "GSM Arena", "numeric_value" => 77.0},
        %{"value" => "73%", "source" => "AnandTech", "numeric_value" => 73.0}
      ]
    }
  },
  %{
    slug: "xiaomi-14",
    name: "Xiaomi 14",
    category: "phones",
    specs: %{
      "brand" => "Xiaomi",
      "model" => "14",
      "battery_mah" => 4610,
      "display_size" => 6.36,
      "ram_gb" => 12,
      "storage_gb" => 256,
      "os" => "Android 14",
      "stability" => [
        %{"value" => "69%", "source" => "GSM Arena", "numeric_value" => 69.0},
        %{"value" => "64%", "source" => "AnandTech", "numeric_value" => 64.0}
      ]
    }
  }
]

Enum.each(phones, fn attrs ->
  %Product{}
  |> Product.changeset(%{
    id: Ecto.UUID.generate(),
    name: attrs.name,
    slug: attrs.slug,
    category: attrs.category,
    specs: attrs.specs
  })
  |> Repo.insert(
    on_conflict: {:replace_all_except, [:id, :inserted_at]},
    conflict_target: [:category, :slug]
  )
end)

IO.puts("Seeded #{length(phones)} phones into the phone category")
