perfdata-monitor-app
====================

Performance data monitor solution for Docker hosts and containers with Prometheus, Grafana, cAdvisor and terraform-resgen (terraform resource generator).

## Prerequisites:

* Docker Engine version 1.13
* Docker Compose version 1.21.2

## Install

1. Clone (or download) this repository on your Docker host
2. Go to perfdata-monitor-app directory
3. Compose the containers in attached mode in order to see the terraform resources being printed out every 5 seconds.

```bash
git clone https://github.com/raolivei/perfdata-monitor-app
cd  perfdata-monitor-app/ 
docker-compose up --remove-orphans
```
To save space on disk, use ``--remove-orphans`` flag to delete orphan images after deployment.

Alternatively, you can set credentials for Grafana: 
```ADMIN_USER=admin ADMIN_PASSWORD=admin docker-compose up```

If not specified, default login credentials are applied ```(admin/admin)```

### List of images after deployment:
```bash
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
terraform-resgen    latest              5cdb18d22327        8 hours ago         185MB
<none>              <none>              fae4c5d55707        8 hours ago         830MB
prom/prometheus     latest              44a4c1c270dc        7 days ago          119MB
buildpack-deps      stretch             6e3b491f9eca        9 days ago          830MB
grafana/grafana     latest              4700307f41f2        4 weeks ago         238MB
debian              stretch             8626492fecd3        6 weeks ago         101MB
google/cadvisor     latest              75f88e3ec333        6 months ago        62.2MB
```

## Containers:

* Prometheus (metrics database) `http://<host-ip>:9090`
* cAdvisor (containers metrics collector) `http://<host-ip>:8080`
* Grafana (visualize metrics) `http://<host-ip>:3000`
* terraform-resgen (terraform resource generator) > *ports not exposed*

### terraform-resgen container:
* Ruby 2.6-rc image used: ``ruby/2.6-rc/stretch/slim`` - *Image size after deployment: 185MB*.
* Dockerfile: ``/perfdata-monitor/terraform/resgen/Dockerfile-terraform-resgen``
* Infinite loop ruby program: ``/perfdata-monitor/terraform/resgen/resource-collector.rb``
* *``bash output``* > terraform resources parsed from YAML to HCL (HashiCorp/Terraform), scanning source file and printed out every 5 seconds.

### Prometheus metrics:
Raw metrics can be inspected by visiting 
``http://localhost:9090/metrics/``

*All data from Prometheus is persistent as docker volumes were specified in docker-compose.yml.*

### Grafana:
Navigate to `http://<host-ip>:3000` and login with user **admin** password **admin**. You can change the credentials in the compose file or by supplying the `ADMIN_USER` and `ADMIN_PASSWORD` environment variables on compose up (see Install instructions).

Grafana is preconfigured with dashboards and **'prometheus'** as the default data source:
* Name: prometheus
* Type: Prometheus
* Url: http://prometheus:9090
* Access: proxy
* basicAuth: false

*All data from Grafana is persistent as docker volumes were specified in docker-compose.yml.*


## Grafana metrics:
### container-monitor Dashboard

- CPU Load: sum(rate(container_cpu_user_seconds_total{image!=""}[1m])) / count(machine_cpu_cores) * 100
- CPU Cores: machine_cpu_cores
- Memory load: sum((go_memstats_frees_total)/(go_memstats_alloc_bytes_total))*1000
- Used Memory: sum(container_memory_usage_bytes{image!=""})
- Storage Load: sum((container_fs_inodes_free)/(container_fs_inodes_total))
- Used Storage: sum(container_fs_usage_bytes)
- Running Containers: scalar(count(container_memory_usage_bytes{image!=""}) > 0)
- File System Load: sum(container_fs_inodes_free/container_fs_inodes_total)*10
- I/O Usage: sum(irate(container_fs_reads_bytes_total[5m])); sum(irate(container_fs_writes_bytes_total[5m])); sum(irate(container_fs_io_time_seconds_total[5m]))
- Container CPU Usage: sum by (name) (rate(container_cpu_usage_seconds_total{image!=""}[1m])) / scalar(count(machine_cpu_cores)) * 100
- Container Memory Usage: sum by (name)(container_memory_usage_bytes{image!=""})
- Container Cached Memory Usage: sum by (name) (container_memory_cache{image!=""})
- Container Network Input: sum by (name) (rate(container_network_receive_bytes_total{image!=""}[1m]))
- Container Network Output: sum by (name) (rate(container_network_transmit_bytes_total{image!=""}[1m]))

![containers-monitor](https://github.com/raolivei/perfdata-monitor-app/blob/master/grafana-screens/containers-monitor.png)

### services-monitor Dashboard


- prometheus Uptime: (time() - process_start_time_seconds{instance="localhost:9090",job="prometheus"})
- Memory Usage: sum(container_memory_usage_bytes)
- In-Memory Chunks: prometheus_tsdb_head_chunks
- In-Memory Series: prometheus_tsdb_head_series
- Container CPU Usage: sum(rate(container_cpu_user_seconds_total[1m]) * 100  / scalar(count(machine_cpu_cores))) by (name)
- Container Memory Usage: sum(container_memory_usage_bytes) by (name)
- Chunks to persist: Data Source (default)
- Persistence Urgency: Data Source (default)
- Chunk ops: Data Source (default)
- Checkpoint duration: Data Source (default)
- Prometheus Engine Query Duration 5m rate: rate(prometheus_engine_query_duration_seconds[5m])
- Target Scrapes: rate(prometheus_target_interval_length_seconds_count[5m])
- Scrape Duration: prometheus_target_interval_length_seconds{quantile!="0.01", quantile!="0.05"}
- HTTP Requests: sum(irate(http_request_total[1m]))
- Alerts: Data Source (default) 

![services-monitor](https://github.com/raolivei/perfdata-monitor-app/blob/master/grafana-screens/services-monitor.png)
