# Open Source Routing Machine (OSRM)

- [🔍 Key Features](#-key-features)
- [⚙️ Architecture Overview](#-architecture-overview)
- [🧩 Core Components](#-core-components)
- [🌐 HTTP API Endpoints](#-http-api-endpoints)
- [🛠 Routing Profiles](#-routing-profiles)

The **Open Source Routing Machine (OSRM)** is a lightning-fast routing engine for road networks, built on top of data from [OpenStreetMap](https://www.openstreetmap.org/). Designed for performance, OSRM delivers real-time route computation, distance matrices, and turn-by-turn directions at scale.

OSRM is ideal for applications where fast, customizable, and reliable routing is essential — including fleet management, mapping services, mobility platforms, and traffic simulations.

---

## 🔍 Key Features

- 🚗 **Ultra-fast routing** based on preprocessed graph data
- 🧭 **Turn-by-turn navigation** with street names and maneuver types
- 🔁 **Customizable routing profiles** (car, bike, foot, etc.) via Lua scripts
- 🛠 **Flexible HTTP API**, compatible with modern web and mobile apps
- 📍 **Supports nearest point queries**, trip optimization, and map matching
- 🧪 **Experimental algorithms** like contraction hierarchies and multi-level Dijkstra

---

## ⚙️ Architecture Overview

OSRM operates in two distinct stages:

### 1. **Preprocessing**

This stage processes the raw OSM data (`.osm.pbf`) into an optimized graph structure for efficient querying. It includes:

- **Parsing OSM data** using `osrm-extract` with a Lua profile to model routing behavior
- **Graph partitioning and customization** using `osrm-partition` and `osrm-customize`, which prepare data for the **MLD (Multi-Level Dijkstra)** algorithm

This is a computationally intensive but one-time setup step per dataset.

### 2. **Routing**

Once preprocessed, the `osrm-routed` server is launched to handle HTTP requests. It loads the optimized graph and serves real-time responses to routing queries, such as:

- Route calculation
- Nearest road snapping
- Matrix (distance/time) computation
- Map matching for GPS traces
- Trip optimization (solving the traveling salesman problem)

---

## 🧩 Core Components

| Component       | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `osrm-extract` | Extracts routing-relevant data from an OSM file using a Lua profile         |
| `osrm-partition` | Divides the graph for MLD routing, optimizing it for performance         |
| `osrm-customize` | Applies routing profile weights and edge properties to the partitioned graph |
| `osrm-routed`   | Runs a web server to serve the OSRM API over HTTP                          |

---

## 🌐 HTTP API Endpoints

OSRM exposes a well-documented HTTP API with various services:

| Endpoint              | Description                                                           |
|-----------------------|-----------------------------------------------------------------------|
| `/route/v1/{profile}/{coordinates}`   | Calculates a route between coordinates                                 |
| `/nearest/v1/{profile}/{coordinates}` | Finds the closest routable point to input coordinates                  |
| `/table/v1/{profile}/{coordinates}`   | Computes duration/distance matrices for multiple coordinates           |
| `/match/v1/{profile}/{coordinates}`   | Snaps noisy GPS traces to road network (map matching)                  |
| `/trip/v1/{profile}/{coordinates}`    | Solves optimal round-trip for the given locations                      |
| `/tile/v1/{profile}/{x}/{y}/{z}.mvt`  | Returns vector tiles (useful for visualizing routing graphs)          |

Each endpoint supports **query parameters** to customize behavior, including `annotations`, `overview`, `geometries`, `steps`, and `hints`.

API reference: [OSRM HTTP API Docs](https://github.com/Project-OSRM/osrm-backend/blob/master/docs/http.md)

---

## 🛠 Routing Profiles

OSRM uses **Lua scripting** to define the behavior of routing profiles. These profiles determine:

- Allowed road types and access restrictions
- Speed assumptions per road category
- Penalties for turns or road features
- Travel mode (e.g., car, bicycle, pedestrian)

Profiles like `car.lua`, `bicycle.lua`, and `foot.lua` are included in the OSRM source and can be customized for specialized use cases (e.g., emergency vehicles or delivery robots).

---
