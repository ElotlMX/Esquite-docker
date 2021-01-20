# Docker Image - Esquite Framework

## v0.1
- Esquite Core components
- External Elasticseach needed via ENV variable
- `TODO`: Buil-in elasticsearch
### Usage:
```
git clone https://github.com/ElotlMX/Esquite-docker.git
cd Esquite-docker
```
- Configure ENV vars in docker compose. 
- *Mandatory* parameters in `v0.1` : URL of a Elasticsearch API (`CFG_URL`)  and existing INDEX name  (`CFG_INDEX`)

- Start up with docker-compose

```
docker-compose up -d
```

- Browse  `http://CONTAINER_IP`



