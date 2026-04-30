# PhD Mobility Project

## Table of Contents

- [PhD Mobility Project](#phd-mobility-project)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Pre-requisites](#pre-requisites)
  - [Project Documentation](#project-documentation)
  - [Docker Setup](#docker-setup)
    - [Shared Network](#shared-network)
    - [Launching Services](#launching-services)

## Introduction

This is the main repository for the Ph.D. projects focusing on mobility analysis. The project is a microservices-based architecture providing spatial databases, routing engines, weather APIs, and visualization tools.

## Pre-requisites

To run the project, you need the following installed:

- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Python 3.10+](https://www.python.org/)

## Project Documentation

Detailed documentation for each service and the API structure can be found in the [docs/](docs/) directory:

- 📊 **[TimescaleDB](docs/timescaledb.md)**: Time-series database with PostGIS.
- 🗺️ **[OSRM](docs/osrm.md)**: Open Source Routing Machine.
- 🌦️ **[Open-Meteo](docs/openmeteo.md)**: Historical weather data (ERA5).
- ⛰️ **[Open Topo Data](docs/opentopo.md)**: Elevation API.
- 📉 **[Grafana](docs/grafana.md)**: Dashboards and visualization.
- 🗺️ **[Kepler.gl](docs/keplergl.md)**: Large-scale geospatial analysis.
- 🌐 **[API Endpoints](docs/endpoints.md)**: Centralized list of services and ports.

## Docker Setup

The services are containerized and orchestrated via Docker Compose.

### Shared Network

The containers communicate via a dedicated bridge network. Create it before starting the services:

```bash
docker network create mobility-network
```

### Launching Services

To build and start all containers in the background, run:

```bash
docker compose up -d
```

in the dedicated services directory. Each service has its own `docker-compose.yaml` file, which defines the necessary configurations and dependencies.

---

_Note: Service-specific environment variables and configurations are defined in the respective `docker-compose.yaml` files inside the `services/` directory._
