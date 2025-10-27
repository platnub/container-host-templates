# Manuals
## Installation
1. Create stack in Komodo using [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/searxng/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/searxng/.env)
2. Run `openssl rand -hex 32` in a terminal for the secret
3. Deploy the stack using Komodo
4. Destroy the container
5. Connect to the host through SSH with sudo privledges and edit `nano /var/lib/docker/volumes/searxng_searxng.etc/_data/settings.yml`
   ```
   search:
     autocomplete: "google"
     favicon_resolver: "google"
   outgoing:
     request_timeout: 10.0
     proxies:
     all://:
       - socks5h://tor:9050
     using_tor_proxy: true
   ```
