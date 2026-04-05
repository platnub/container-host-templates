---
title: README
description: 
published: true
date: 2026-04-05T21:41:16.565Z
tags: 
editor: markdown
dateCreated: 2026-04-05T21:01:58.822Z
---

# Install

## Docker

> Tested with Proxmox 8.x.x - 9.1.x
> - Root user disabled
> - Sudo user username = hostname
{.is-info}

1. Run this from Proxmox node shell
   ```
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/platnub/titan-server/refs/heads/main/proxmox/scripts/docker.sh)"
   ```
   1. ...option 1

### Post-install

 - [Docker configuration](https://github.com/platnub/container-host-templates/blob/main/docker/README.md)
