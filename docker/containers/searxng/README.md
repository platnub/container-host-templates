# Manuals
## Installation
1. Create stack in Komodo using [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/searxng/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/searxng/.env)
2. Run `openssl rand -hex 32` in a terminal for the secret
3. Connect to the host using SSH with sudo permissions and run:
```
docker volume create searxng_searxng.etc && cd /var/lib/docker/volumes/searxng_searxng.etc/_data && wget -O settings.yml  https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/searxng/settings.yml
```
4. Optionally edit the file and add optional engines
5. Deploy the stack using Komodo

## Extra Search Engine options
 - [Astrophysics Data System (ADS) - API key](https://ui.adsabs.harvard.edu/help/api/) _[searxng](https://docs.searxng.org/dev/engines/online/astrophysics_data_system.html)_
 - [Core AC UK](https://core.ac.uk/services/api) _[searxng](https://docs.searxng.org/dev/engines/online/core.html)_
