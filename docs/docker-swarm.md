## Network Setup

We need to set up a network for our Docker Swarm cluster to allow communication between the manager and worker nodes. We will create an overlay network that will be used by all the services in our swarm.

```bash
docker network create -d overlay --attachable mobility-network
```

Make sure to run this command on the manager node, as it will create the network for the entire swarm. The `--attachable` flag allows standalone (test) containers to be attached to the network, which is necessary for our services to communicate with each other.

## NFS Setup

We need to share the configuration files of the services between the manager and worker nodes for Monitoring and Data Collection. To achieve this, we will use NFS (Network File System) to share the configuration files between the nodes.

The manager node will host the configuration files for Loki and Alloy, while the worker nodes will host the configuration files for the data collectors. We will set up NFS on the manager node to share the configuration files with the worker nodes. The worker node will host the configuration files for the data collectors and share them with the manager node to be used by the services running on the manager node. No other sharing of configuration files is necessary, as the services running on the manager node will only need access to their own configuration files.

1. Install NFS on the manager and worker nodes:

```bash
apk add nfs-utils
```

2. Activate NFS server on the manager and worker nodes:

```bash
rc-update add nfs
rc-update add rpcbind
rc-service nfs start
rc-service rpcbind start
```

All file shares are listed in the dedicated service sections of the documentation, so we will not list them here again. Please refer to the setup of Loki, Alloy, and the data collectors for the specific file shares that need to be set up.

## Service Setup

### Loki and Alloy

For monitoring, we will set up Loki and Alloy. Loki solely runs on the manager node, while Alloy runs on all nodes in the swarm. The configuration files for both services will be hosted on the manager node and shared with the worker nodes via NFS.

1. On the manager node, verify that the configuration files for Loki and Alloy are in place:

```bash
ls /root/main/services/loki/config-swarm.yaml
ls /root/main/services/alloy/config-swarm.yaml
```

2. On the worker node, we need to create the directories for the configuration files of Loki and Alloy, as they will be shared from the manager node:

```bash
mkdir -p /root/main/services/loki/
mkdir -p /root/main/services/alloy/
```

3. Now we set up the NFS shares for the configuration files of Loki and Alloy on the manager node, so that they can be accessed by the worker nodes:

```bash
echo "/root/main/services/loki <worker-node-ip-range>.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
echo "/root/main/services/alloy <worker-node-ip-range>.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -ra
```

On the worker node, we need to mount the NFS shares for the configuration files of Loki and Alloy:

```bash
mount -t nfs <manager-node-ip>:/root/main/services/loki /root/main/services/loki
mount -t nfs <manager-node-ip>:/root/main/services/alloy /root/main/services/alloy
echo "<worker-node-ip>:/root/main/services/loki /root/main/services/loki nfs defaults 0 0" >> /etc/fstab
echo "<worker-node-ip>:/root/main/services/alloy /root/main/services/alloy nfs defaults 0 0" >> /etc/fstab
```

4. Start the Docker services for Loki and Alloy on the manager node:

```bash
docker stack deploy -c /root/main/services/loki/docker-compose-swarm.yaml monitoring
docker stack deploy -c /root/main/services/alloy/docker-compose-swarm.yaml monitoring
```

### Nextbike Collector (OK)

The Nextbike Collector is a data collection service that runs on all worker nodes in the swarm. The configuration file for the Nextbike Collector will be hosted on the worker nodes and shared with the manager node via NFS.

1. On the manager node, clone the GitHub repository for the Nextbike Collector:

```bash
git clone https://github.com/PhD-Kerger/nextbike-collector.git /root/data-collection/nextbike-collector
```

2. Create the configuration file for the Nextbike Collector on the manager node:

```bash
mv /root/data-collection/nextbike-collector/example.values.yaml /root/data-collection/nextbike-collector/values.yaml
```

3. Create the output directory for the Nextbike Collector on the worker node:

```bash
mkdir -p /root/data/nextbike-collector/output-json
mkdir -p /root/data/nextbike-collector/output-parquet
```

4. Now we set up the NFS shares for the configuration and docker-compose-swarm file of the Nextbike Collector on the manager node, so that it can be accessed by the worker node:

```bash
echo "/root/data-collection/nextbike-collector <worker-node-ip-range>.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -ra
```

On the worker node, we need to create the directories for the configuration file of the Nextbike Collector, as it will be shared from the manager node and the data directories for the output of the Nextbike Collector:

```bash
mkdir -p /root/data-collection/nextbike-collector
mkdir -p /root/data/nextbike-collector/output-json
mkdir -p /root/data/nextbike-collector/output-parquet
```

Now we need to mount the NFS shares for the configuration file of the Nextbike Collector on the worker node:

```bash
mount -t nfs <manager-node-ip>:/root/data-collection/nextbike-collector /root/data-collection/nextbike-collector
echo "<manager-node-ip>:/root/data-collection/nextbike-collector /root/data-collection/nextbike-collector nfs defaults 0 0" >> /etc/fstab
```

5. Finally, we can start the Docker service for the Nextbike Collector on the manager node:

```bash
docker stack deploy -c /root/data-collection/nextbike-collector/docker-compose-swarm.yaml collectors
```






Testing with busybox:

```bash
docker service create \
  --name logtest \
  --network mobility-network \
  busybox \
  sh -c 'while true; do echo "HELLO $(hostname) $(date)"; sleep 2; done'

curl --get --data-urlencode 'query={container=~".+"}' http://192.168.56.104:5006/loki/api/v1/query
```


curl -G "http://192.168.56.104:3100/loki/api/v1/query" --data-urlencode 'query={container=~"nextbike.\*"}'
