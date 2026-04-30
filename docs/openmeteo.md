# Open-Meteo API Service

- [Open-Meteo API Service](#open-meteo-api-service)
  - [🔍 Key Features](#-key-features)
  - [⚙️ Setup Instructions](#️-setup-instructions)
  - [🌐 HTTP API Endpoints](#-http-api-endpoints)
  - [📊 Example Usage](#-example-usage)

The **Open-Meteo API** service provides access to historical weather data using local ERA5 datasets. It is a high-performance alternative to external weather APIs, allowing for offline processing and faster queries.

---

## 🔍 Key Features

- 🌦 **Historical Weather**: Access ERA5 data from March 2023 to April 2026.
- 🚀 **Local Performance**: Zero-latency queries served from your local machine.
- 🛠 **Customizable Variables**: Support for temperature, precipitation, wind components, and more.
- 🧭 **Standardized API**: Compatible with the official Open-Meteo API structure.

---

## ⚙️ Setup Instructions

To set up the Open-Meteo API, you first need to download the ERA5 data using the `openmeteo-api` command-line tool.

1. **Download Data**: Run the following command inside the container terminal (adjusting the time interval and CDS key):

   ```bash
   ./openmeteo-api download-era5 era5 \
     --timeinterval 20230330-20260415 \
     --cdskey YOUR_CDS_KEY \
     --force \
     --only-variables temperature_2m,precipitation,wind_u_component_10m,wind_v_component_10m,dew_point_2m
   ```

2. **Persistence**: We only need to download the data once. The data is stored in the local `data/copernicus_era5/` directory and served via the API. The `--force` flag ensures that data is used in the conversion process even if previously downloaded.

---

## 🌐 HTTP API Endpoints

The service runs on port **5005** and exposes several endpoints:

| Endpoint      | Method | Description                    |
| :------------ | :----- | :----------------------------- |
| `/v1/archive` | GET    | Query historical weather data. |

---

## 📊 Example Usage

**Querying historical archive:**

```http
http://localhost:5005/v1/archive?latitude=52.52&longitude=13.41&start_date=2023-03-30&end_date=2026-04-15&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,precipitation
```

The API returns weather variables in JSON format for the specified coordinates and time range.
