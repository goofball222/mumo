# Mumble Mumo Docker Container

[![Docker Build Status](https://img.shields.io/docker/cloud/build/goofball222/mumo.svg)](https://hub.docker.com/r/goofball222/mumo/) [![Docker Pulls](https://img.shields.io/docker/pulls/goofball222/mumo.svg)](https://hub.docker.com/r/goofball222/mumo/) [![Docker Stars](https://img.shields.io/docker/stars/goofball222/mumo.svg)](https://hub.docker.com/r/goofball222/mumo/) [![MB Layers](https://images.microbadger.com/badges/image/goofball222/mumo.svg)](https://microbadger.com/images/goofball222/mumo) [![MB Commit](https://images.microbadger.com/badges/commit/goofball222/mumo.svg)](https://microbadger.com/images/goofball222/mumo) [![MB License](https://images.microbadger.com/badges/license/goofball222/mumo.svg)](https://microbadger.com/images/goofball222/mumo)

## Docker tags:
| Tag | Description | Release Date |
| --- | --- | :---: |
| [latest](https://github.com/goofball222/mumo/blob/master/stable/Dockerfile) | Latest stable release | 2019-06-28 |
| [release-1.0.2](https://github.com/goofball222/mumo/releases/tag/1.0.1) | Static stable release tag/image | 2019-06-28 |

---

* [Recent changes, see: GitHub CHANGELOG.md](https://github.com/goofball222/mumo/blob/master/CHANGELOG.md)
* [Report any bugs, issues or feature requests on GitHub](https://github.com/goofball222/mumo/issues)

---

## Usage

This container exposes two volumes:
* `/opt/mumo/config` - Mumo and module configuration - **REQUIRED:** this must be mapped to a persistent volume or the container will not work.
* `/opt/mumo/logs` - Mumo logs for troubleshooting


This container exposes NO PORTS. It must be connected to the Murmur server container via Docker container network sharing.

---

**The most basic way to run this container:**

```bash
$ docker run --name mumo -d \
    --net=container:<murmur container id> \
    -v ./config:/opt/mumo/config  \
    goofball222/mumo
```  
---

**Recommended: run via [Docker Compose](https://docs.docker.com/compose/):**

Have the container store the config & logs on a local file-system or in a specific, known data volume (recommended for persistence and troubleshooting), bring up in concert with Murmur:

```bash

version: '3'

services:
  murmur:
    image: goofball222/murmur
    container_name: murmur
    ports:
      - 64738:64738
      - 64738:64738/udp
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./data:/data
      - ./murmur.ini:/etc/murmur.ini
    environment:
      - TZ=UTC

  mumo:
    image: goofball/mumo
    container_name: mumo
    network_mode: service:murmur
    depends_on:
      - murmur
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./config:/opt/mumo/config
      - ./log:/opt/mumo/log
    environment:
      - TZ=UTC

```

[Example `docker-compose.yml` file](https://raw.githubusercontent.com/goofball222/mumo/master/examples/docker-compose.yml)

---

**Environment variables:**

| Variable | Default | Description |
| :--- | :---: | --- |
| `DEBUG` | ***false*** | Set to *true* for extra entrypoint script verbosity for debugging |
| `MUMO_OPTS` | ***unset*** | Any additional custom run flags for the container mumo.py script |
| `PGID` | ***999*** | Specifies the GID for the container internal mumo group (used for file ownership) |
| `PUID` | ***999*** | Specifies the UID for the container internal umumo user (used for process and file ownership) |
| `RUN_CHOWN` | ***true*** | Set to *false* to disable the container automatic `chown` at startup. Speeds up startup process on overlay2 Docker hosts. **NB/IMPORTANT:** It's critical that you insure directory/data permissions on all mapped volumes are correct before disabling this or mumo will not start. |
| `RUNAS_UID0` | ***false*** | Set to *true* to force the container to run the mumo.py script as UID=0 (root) - **NB/IMPORTANT:** running with this set to "true" is insecure |

---

[//]: # (Licensed under the Apache 2.0 license)
[//]: # (Copyright 2018 The Goofball - goofball222@gmail.com)
