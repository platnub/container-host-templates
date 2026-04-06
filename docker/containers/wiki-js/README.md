---
title: Wiki.js 
description: 
published: true
date: 2026-04-06T10:10:29.071Z
tags: 
editor: markdown
dateCreated: 2026-04-06T09:59:40.308Z
---

# Info
> **_Pangolin Connection_**
> - http://wiki_js-public-wiki:3000
>   - Unprotected
>   - **Rules**
>     - 1
>       - IP: `x`
>       - Bypass Auth
>     - 2
>       - Path `/login`
>       - Block Access
<!-- {blockquote:.is-info} -->

<details><summary>compose.yml</summary>

```yml
########################### NETWORKS
networks:
  internal:
  wiki_js-public:
    external: true

########################### VOLUMES
volumes:
  db-data:

########################### SERVICES
services:
  db:
    container_name: wiki_js-public-db
    image: postgres:15-alpine
    restart: unless-stopped
    networks:
      - internal
    environment:
      POSTGRES_DB: wiki
      POSTGRES_PASSWORD: wikijsrocks
      POSTGRES_USER: wikijs
    logging:
      driver: none
    volumes:
      - db-data:/var/lib/postgresql/data

  wiki:
    container_name: wiki_js-public-wiki
    image: ghcr.io/requarks/wiki:2
    restart: unless-stopped
    networks:
      - internal
      - wiki_js-public
    depends_on:
      - db
    environment:
      DB_TYPE: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: wikijs
      DB_PASS: wikijsrocks
      DB_NAME: wiki
```

</details>