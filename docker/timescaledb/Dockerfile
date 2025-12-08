FROM postgres:17

RUN apt-get update && \
    apt-get install -y gnupg postgresql-common apt-transport-https lsb-release wget postgresql-17-postgis-3 sudo ca-certificates unzip && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/timescaledb.list

RUN wget --no-check-certificate -qO - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/timescaledb.gpg

# Fixes Certificate verification failed in some networks
RUN echo 'Acquire::https::Verify-Peer "false";' > /etc/apt/apt.conf.d/99disable-verification && \
    apt-get update
    
RUN apt install timescaledb-2-postgresql-17 postgresql-client-17 -y && \
    rm -rf /var/lib/apt/lists/*

# Install DuckDB
RUN wget https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip && \
    unzip duckdb_cli-linux-amd64.zip && \
    mv duckdb /usr/local/bin/ && \
    rm duckdb_cli-linux-amd64.zip && \
    chmod +x /usr/local/bin/duckdb

COPY docker/data/timescaledb/config/postgresql.conf /

# Copy DuckDB Extensions
COPY docker/timescaledb/postgres_scanner.duckdb_extension.tar.gz /
COPY docker/timescaledb/spatial.duckdb_extension.tar.gz /
# Extract DuckDB Extensions
RUN mkdir -p /var/lib/postgresql/duckdb_extensions && \
    tar -xzf /spatial.duckdb_extension.tar.gz -C /var/lib/postgresql/duckdb_extensions && \
    tar -xzf /postgres_scanner.duckdb_extension.tar.gz -C /var/lib/postgresql/duckdb_extensions && \
    rm /spatial.duckdb_extension.tar.gz /postgres_scanner.duckdb_extension.tar.gz
    
# Install DuckDB Extensions globally
RUN duckdb -c "INSTALL '/var/lib/postgresql/duckdb_extensions/spatial.duckdb_extension';" && \
    duckdb -c "INSTALL '/var/lib/postgresql/duckdb_extensions/postgres_scanner.duckdb_extension';"

# TimescaleDB must be loaded as a shared_preload_libraries, else it won't get loaded.
RUN echo "shared_preload_libraries = 'timescaledb'" >> /usr/share/postgresql/postgresql.conf.sample

# append the /postgresql.conf to the default config
RUN echo "include_if_exists = '/postgresql.conf'" >> /usr/share/postgresql/postgresql.conf.sample