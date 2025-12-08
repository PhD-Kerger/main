# Main Repository

## Table of Contents

- [Main Repository](#main-repository)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Pre-requisites](#pre-requisites)
  - [Docker](#docker)
    - [TimescaleDB](#timescaledb)
      - [Restore, Dump, Truncate \& Materialized Views](#restore-dump-truncate--materialized-views)
        - [Restoring Data](#restoring-data)
        - [Dumping Data](#dumping-data)
        - [Truncating Data](#truncating-data)
        - [Materialized Views](#materialized-views)
    - [Tune Parameters](#tune-parameters)
    - [Kepler.gl](#keplergl)
    - [OSRM (Open Source Routing Machine)](#osrm-open-source-routing-machine)

## Introduction

This is the main repository for the Ph.D. projects. The project is divided into several sub-projects, each with its own repository.

## Pre-requisites

To clone all other projects, you need to have the following installed:

- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Python 3.10.12](https://www.python.org/) (optional)
- [DBeaver](https://dbeaver.io/) (optional)

## Docker

There are three Dockerfiles in this repository, one for a TimescaleDB database, one for a Kepler.gl instance, and one for an OSRM (Open Source Routing Machine) instance. The Dockerfiles are located in the `docker` directory. The Dockerfiles are used to build the images for the containers. The images are built automatically when you run the `docker-compose up` command. The Docker Container need a network to communicate with each other. The network can be created with the following command:

```bash
docker network create mobility-network
```

To start all containers, run the following command in the root directory of this repository:

```bash
docker compose up -d
```

in the root directory of this repository. It will automatically build the images and start the containers. Further, there are environment variables defined in the `docker-compose.yml` file that can be changed. If already a service is running on one of the ports `5432`, `8080` or `5000` the  container cannot be started. To suspend the application, execute

```bash
sudo kill -9 $(sudo lsof -t -i:<PORT>)
```

or change the port in the `docker-compose.yml` file.

### TimescaleDB

The TimescaleDB container is based on Postgres 17 and has both the TimescaleDB extension and the PostGIS extension installed. It is available on port 5432, with the database `mobility` being created automatically. Username and password are defined in the `docker-compose.yml` file and can be changed there.

The following environment variables are defined in the `docker-compose.yml` file:

- `POSTGRES_USER`: The username for the TimescaleDB database.
- `POSTGRES_PASSWORD`: The password for the TimescaleDB database.
- `POSTGRES_DB`: The name of the database to be created.
- `POSTGRES_CREATE_MATVIEWS`: If set to `true`, the continuous aggregates will be created.

#### Restore, Dump, Truncate & Materialized Views

To restore and dump the database, please follow the official [TimescaleDB documentation](https://docs.timescale.com/self-hosted/latest/backup-and-restore/logical-backup/#back-up-and-restore-an-entire-database) and use the scripts in the `./docker/timescaledb/scripts` directory.

##### Restoring Data

First, import the database schema, then the data. When setting up the container, the database schema (no data ingestion) will be created automatically. The Parquet files containing the data need to be copied to the `docker/data/timescaledb/data` directory. Then, after connecting to the container, run the `import_data.sh` script to import the data. If the availability data should also be imported, set the environment variable `POSTGRES_ENABLE_AVAILABILITY` to `true` in the `docker-compose.yml` file before starting the container. The import of the availability data takes a long time, as it contains more than 2 billion rows.

##### Dumping Data

To dump the database, use the `dump_database.sh` script. The dump will be created in the `docker/data/timescaledb/backup` directory.

##### Truncating Data

To truncate the complete database, use the `truncate_database.sh` script. This will delete all data in the database, but keep the schema. After truncating the database, the data can be re-imported using the `import_data.sh` script.

##### Materialized Views

To create the materialized views, set the environment variable `POSTGRES_CREATE_MATVIEWS` to `true` in the `docker-compose.yml` file before starting the container. To create the materialized views, run the `create_matviews.sh` script. The materialized views will be created automatically when the container is started if the environment variable is set to `true`. A description of the materialized views can be found in the `./docker/timescaledb/README.md` file.

### Tune Parameters

The parameters for the TimescaleDB container can be tuned with the tool `timescaledb-tune`. The tool can be installed **in the container** by following the instructions in the [TimescaleDB documentation](https://github.com/timescale/timescaledb-tune).

Inside the container, run the following command to tune the parameters:

```bash
timescaledb-tune --memory="12GB" --quiet --yes --dry-run --conf-path=/usr/share/postgresql/postgresql.conf.sample
```

### Kepler.gl

The Kepler.gl container is based on the Kepler.gl project and is available on port 8080. It is used to visualize the data in the TimescaleDB database. To use the service, you need to have a valid (free) API key for the Mapbox service. The API key can be set in the `docker-compose.yml` file in the `MAPBOX_ACCESS_TOKEN` environment variable. You can get a free API key from the [Mapbox website](https://www.mapbox.com/).

As Kepler.gl runs in the browser, a limit of 500MB is set for the data that can be loaded. This is a limitation of the browser and not of the Kepler.gl project. A direct loading from a Jupyter Notebook or the TimescaleDB database is not possible. If the data surpasses this limit, use the `kepler.gl` Python package to analyze the data directly in Python. The package can be installed via pip:

```bash
pip install keplergl
```

### OSRM (Open Source Routing Machine)

The OSRM container is based on the OSRM project and is available on port 5000. It is used to calculate routes between two points. The OSM data is stored in the `docker/data/osrm/data` directory. The data can be downloaded from the [Geofabrik website](https://download.geofabrik.de/). The data is automatically extracted, partitioned, and customized when the container is started. Currently, the default dataset is the latest OSM data for Baden-Württemberg.

The documentation for the OSRM project can be found [here](https://project-osrm.org/docs/v5.24.0/api/). In Python, create requests to the OSRM API using the `requests` package. The package can be installed via pip:

```bash
pip install requests
```

The following example shows how to create a request to the OSRM API:

```python
import requests

# Example request to the OSRM API to calculate a route on the bike network from (8.681495, 49.414445) to (8.686507, 49.41943)
response = requests.get(
    "http://localhost:5000/route/v1/bike/8.681495,49.414445;8.686507,49.41943?overview=false"
)
data = response.json()
print(data)
```

The response is a JSON object containing the route information. The coordinates are in the format `longitude,latitude`. The OSRM API supports several profiles, including `driving`, `walking`, and `cycling`. The profile can be changed in the URL.
