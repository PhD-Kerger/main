# kepler.gl

- [🌍 Key Features](#-key-features)
- [🧱 Architecture Overview](#-architecture-overview)
- [🔧 Core Components](#-core-components)
- [📁 Supported Data Formats](#-supported-data-formats)
- [🎨 Visualization Layers](#-visualization-layers)

**kepler.gl** is a powerful open-source geospatial analysis tool for large-scale datasets. Developed by Uber's Visualization team, it provides an intuitive UI for visualizing geospatial data directly in the browser, without writing any code.

It’s especially well-suited for exploring movement data, point clouds, transportation systems, urban planning models, and more.

---

## 🌍 Key Features

- 🗺 **Interactive map-based visualization** with high performance rendering via WebGL
- 📊 **Drag-and-drop UI** for loading CSV, GeoJSON, and other spatial data formats
- 🔍 **Support for time animation**, filters, and layer blending
- 🎨 **Rich layer types**: point, arc, heatmap, cluster, hexbin, trip, and more
- 🧩 **Integration-ready**: can be embedded in React apps or run standalone
- 🔄 **Export maps** to JSON for saving and reloading projects

---

## 🧱 Architecture Overview

kepler.gl is built as a modular, extensible web application on top of these technologies:

- **React**: UI framework
- **Redux**: State management for map configuration and layers
- **deck.gl**: Rendering engine for scalable WebGL-based visualizations
- **mapbox-gl**: Provides the base map and geospatial context

It uses GPU acceleration to handle datasets with **millions of rows** in the browser without significant performance issues.

---

## 🔧 Core Components

| Component      | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `KeplerGl`     | Main React component, encapsulates map rendering and UI logic               |
| `deck.gl`      | Underlying WebGL engine used to draw and animate visual layers              |
| `mapbox-gl`    | Background map engine, supports basemap styling and zooming                 |
| `Redux store`  | Maintains application state: datasets, filters, layers, map style, etc.     |
| `kepler.gl schemas` | JSON schemas that allow importing/exporting complete map configurations |

---

## 📁 Supported Data Formats

You can load data into kepler.gl via drag-and-drop or programmatically:

- **CSV/TSV**: With lat/lon or coordinate pairs
- **GeoJSON**: For complex geometries and custom features
- **JSON**: Saved kepler.gl project files (state snapshots)
- **KML, GPX, shapefiles**: (via preprocessing or community tools)

Data can include spatial (point, line, polygon) and temporal dimensions, enabling dynamic time-based visualizations.

---

## 🎨 Visualization Layers

kepler.gl includes a variety of layer types optimized for different use cases:

- **Point**: Displays latitude/longitude pairs
- **Arc**: Connects origin and destination points
- **Line**: Draws paths and segments
- **Hexbin & Grid**: Aggregated spatial densities
- **Heatmap**: Smoothed data density visualization
- **Trip Layer**: Animated trajectories over time
- **H3 Cluster**: Hierarchical hexagonal binning for big data

Each layer type supports customization (e.g., color, radius, altitude, time playback).

---