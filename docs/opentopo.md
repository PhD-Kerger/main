# Open Topo Data Service

- [Open Topo Data Service](#open-topo-data-service)
  - [🔍 Key Features](#-key-features)
  - [⚙️ Setup Instructions](#️-setup-instructions)
    - [1. Repository Dependency](#1-repository-dependency)
    - [2. Data Provisioning](#2-data-provisioning)
    - [3. Setup Configuration](#3-setup-configuration)
    - [4. Deployment](#4-deployment)
  - [🌐 HTTP API Endpoints](#-http-api-endpoints)
  - [📊 Example Usage](#-example-usage)

The **Open Topo Data** service is a REST API server for your elevation data. It is designed to be a self-hosted alternative to the Google Elevation API, supporting various raster formats and tiling schemes.

---

## 🔍 Key Features

- ⛰️ **Multiple Datasets**: Host SRTM, ETOPO1, ASTER, and other datasets.
- 🧭 **Google API Compatible**: Uses a similar request/response structure.
- 🚀 **High Performance**: Optimized for fast point and series queries.
- 🛠 **Customizable**: Configure interpolation methods and request limits.

---

## ⚙️ Setup Instructions

### 1. Repository Dependency

This service utilizes the [ajnisbet/opentopodata](https://github.com/ajnisbet/opentopodata) repository.

### 2. Data Provisioning

The default dataset is ETOPO1, which is downloaded and processed during the setup phase. The service is configured to serve elevation data from this dataset. Be sure to have enough disk space for the dataset, and `gdal_translate` installed on your system.

### 3. Setup Configuration

A setup script is provided to automate the download and processing of the ETOPO1 dataset. This script will handle the necessary data preparation steps, including downloading the dataset, converting it to the required format, and configuring the service.

```bashcd
cd services/opentopodata
./setup.sh
```

### 4. Deployment

```bash
cd services/opentopodata
docker compose up -d
```

---

## 🌐 HTTP API Endpoints

The service runs on port **5001** and exposes several endpoints:

| Endpoint        | Method   | Description                          |
| :-------------- | :------- | :----------------------------------- |
| `/v1/{dataset}` | GET/POST | Query elevation for coordinates.     |
| `/datasets`     | GET      | List available datasets and extents. |
| `/health`       | GET      | Check service health.                |

---

## 📊 Example Usage

**Querying ETOPO1 elevation:**

```bash
curl "http://localhost:5001/v1/etopo1?locations=49.0069,8.4037"
```

**JSON Response:**

```json
{
  "results": [
    {
      "elevation": 115.0,
      "location": { "lat": 49.0069, "lng": 8.4037 },
      "dataset": "etopo1"
    }
  ],
  "status": "OK"
}
```

un the setup.sh script to download the official openotopo repository

- then download the
