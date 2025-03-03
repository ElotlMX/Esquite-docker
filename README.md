# Docker Image - Esquite Framework v0.3  

## Quick Start  

Version 0.3 of `Esquite-docker` is simpler than v0.2.  

In v0.2, a control script provided multiple configuration options. While useful, it was also prone to errors and somewhat cumbersome.  

This new version works exclusively with a pre-configured Docker Compose setup, reducing the need for manual configuration.  

For additional details, see the `CHANGELOG` file.  

---

### Using Docker Compose Directly  

```sh
git clone https://github.com/ElotlMX/Esquite-docker.git
cd Esquite-docker
docker compose up
```

---

### Accessing the Esquite Web Interface  

To access the web frontend, use the container's IP address.  

- If you run `docker compose` without the `-d` option, Esquite displays the container's IP address after loading.  
- If you run `docker compose` with the `-d` option and no custom Docker network configuration was used, check the container logs to find the IP address:  

```sh
docker logs CONTAINER_NAME
```

**Sample Output:**  

```
esquite-1        | [2025-03-02 23:31:02] Esquite Web is available on
esquite-1        | [2025-03-02 23:31:02] - http://172.18.0.2       
```

Alternatively, you can retrieve the container's IP address using:  

```sh
docker inspect CONTAINER_NAME | grep IPAddress
```

---

### Exposing Ports  

To make Esquite accessible on the local network or the Internet, add the necessary port configuration in the `docker-compose.yaml` file.  

**Example configuration:**  

```yaml
...
    ports:
      - 80:80
...
```

---

### Accessing the Corpus Admin Section  

The management section is available at:  

```
http://[IP-OR-HOSTNAME]/corpus-admin
```

**Default credentials:**  

- **User:** `esquite`  
- **Password:** `elotl`  

---

## Features of This Docker Compose Setup  

### User Directory: `esquite-user`  

The `esquite-user` directory stores all persistent data, ensuring that user-defined settings and uploaded files remain intact even when a new container is created or `Esquite-docker` is upgraded.  

It contains the following:  

- **`env.yaml`** — Configuration file for Esquite  
- **`media/`** — Directory for storing files uploaded via `corpus-admin`  
- **`static-user/`** — Directory for customizing the Esquite frontend  
- **`template-user/`** — Directory for customizing the content of the Esquite frontend  
- **`esquite-http-auth-users.pwd`** — Web authentication configuration file for `corpus-admin` access  

For more details, refer to the Esquite documentation.  

---

### Embedded NGINX Reverse Proxy  

- NGINX is configured as a reverse proxy to handle all HTTP traffic for the Django backend, simplifying deployment.  
- Basic authentication is managed via the file `esquite-user/esquite-http-auth-users.pwd`.  

---

### Elasticsearch Configuration  

If the `docker-compose.yaml` option `CFG_ESQUITE_ELASTICSEARCH` is set to `default-esquite` and the Elasticsearch container configuration is uncommented (default setting), `Esquite-docker` will create and configure an Elasticsearch instance with a default index.  

This option is designed for quick deployment and testing.  

If you already have an Elasticsearch instance, update the `URL` and `Index` fields in `esquite-user/env.yaml` to specify the Elasticsearch instance Esquite should connect to.  

If you plan to use this Elasticsearch container in a production environment, be sure to fine-tune its parameters accordingly (e.g., index name, memory limits, API permissions, etc.).
