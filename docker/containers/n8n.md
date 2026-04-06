---
title: n8n
description: 
published: true
date: 2026-04-06T12:20:29.143Z
tags: 
editor: markdown
dateCreated: 2026-04-05T21:02:21.180Z
---

**_Resource Requirements_** [READ](../../../README.md#resource-requirements):
- **OpenWebUI**
   - limits:
      - cpus: '2.00'
      - memory: 4G
   - reservations:
      - cpus: '1.00'
      - memory: 1G

**_Pangolin Resource configuration_**
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `n8n`
    - Port: `5678`
- Authentication
  - Use Platform SSO: Disabled

<details><summary>compose.yml</summary>

```yml
########################### NETWORKS
networks:
  n8n:
    external: true
#  supabase:
#    external: true
#  searxng:
#    external: true

########################### VOLUMES
volumes:
  data:

########################### SERVICES
services:
  n8n:
    container_name: n8n
    image: docker.n8n.io/n8nio/n8n
    restart: always
    user: ${PUID}:${PGID}
    networks:
      - n8n
#      - supabase
#      - searxng
    volumes:
      - data:/home/node/.n8n
    environment:
      - TZ=${TZ}
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_HOST=${SUBDOMAIN}.${DOMAIN_NAME}
      - N8N_PROXY_HOPS=${N8N_PROXY_HOPS}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - N8N_RUNNERS_ENABLED=${N8N_RUNNERS_ENABLED}
      - NODE_ENV=${NODE_ENV}
      - N8N_PERSONALIZATION_ENABLED=${N8N_PERSONALIZATION_ENABLED}
      - WEBHOOK_URL=https://${SUBDOMAIN}.${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - N8N_SMTP_HOST=${N8N_SMTP_HOST}
      - N8N_SMTP_PORT=${N8N_SMTP_PORT}
      - N8N_SMTP_SSL=${N8N_SMTP_SSL}
      - N8N_SMTP_STARTTLS=${N8N_SMTP_STARTTLS}
      - N8N_SMTP_USER=${N8N_SMTP_USER}
      - N8N_SMTP_PASS=${N8N_SMTP_PASS}
      - N8N_SMTP_SENDER=${N8N_SMTP_SENDER}
    deploy:
      resources:
        limits:
          cpus: '2.00'
          memory: 4G
        reservations:
          cpus: '1.00'
          memory: 1G
```

</details>

<details><summary>.env</summary>

```bash
TZ=Europe/Amsterdam

# DOMAIN_NAME and SUBDOMAIN together determine where n8n will be reachable from
# The top level domain to serve from
DOMAIN_NAME=example.com
# The subdomain to serve from
SUBDOMAIN=n8n
# The above example serve n8n at: https://n8n.example.com
N8N_PROXY_HOPS=1
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_RUNNERS_ENABLED=true
NODE_ENV=production
N8N_PERSONALIZATION_ENABLED=false

# Email setup
N8N_SMTP_HOST= # SMTP server
N8N_SMTP_PORT= # SMTP server port
N8N_SMTP_SSL=false # SMTP SSL
N8N_SMTP_STARTTLS=false # SMTP STARTTLS
N8N_SMTP_USER= # SMTP email user
N8N_SMTP_PASS= # SMTP email password
N8N_SMTP_SENDER= # Email sender
```

</details>

# Useful information
## Community nodes
- [NCNodes- Community built nodes for n8n](https://ncnodes.com)
    - [discord-trigger](https://ncnodes.com/package/n8n-nodes-discord-trigger)

## Extra Information
- [Get workflow static data](https://docs.n8n.io/code/cookbook/builtin/get-workflow-static-data/)

# Manuals

## Setup
1. Deploy container using the compose.yml and .env files in Komodo
2. Create the Pangolin tunnel and connect using https://n8n.example.com
3. Create an admin account
4. Optionally setup a license key
     - 'Settings > Usage plan'

## Create backups
[n8n backup guide](https://docs.n8n.io/embed/deployment/#backups)

### Recommended

- Run daily at 00:45
```
45 0 * * * /usr/local/bin/n8n.sh > /dev/null 2>&1
```

### Create
```
borg create -v --stats \
    $REPOSITORY::n8n_'{now:%Y-%m-%d_%H:%M}' \
    /var/lib/docker/volumes/n8n_data/_data \
    --exclude /var/lib/docker/volumes/n8n_data/_data/crash.journal \
    --exclude '/var/lib/docker/volumes/n8n_data/_data/database.sqlite*' \
    --exclude '/var/lib/docker/volumes/n8n_data/_data/n8nEventLog*.log'
```

## Backup recovery
[BorgBackup - Backup recovery](https://wiki-js-public.alion.host/en/tools/borgbackup#backup-recovery)