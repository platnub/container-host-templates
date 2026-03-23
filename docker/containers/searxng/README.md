> [!NOTE]
> **Resource Requirements** [READ](../../../README.md#resource-requirements):
> - **SearXNG**
>    - limits:
>       - cpus: '0.50'
>       - memory: 1G
>    - reservations:
>       - cpus: '0.10'
>       - memory: 250M
> - **Redis**
>    - limits:
>       - cpus: '0.50'
>       - memory: 2G
>    - reservations:
>       - cpus: '0.10'
>       - memory: 1G
> - **Tor**
>    - limits:
>       - cpus: '0.20'
>       - memory: 250M
>    - reservations:
>       - cpus: '0.10'
>       - memory: 50M

# Manuals
## Installation
1. Create stack in Komodo using [compose.yml](compose.yml) and [.env](.env)
2. Run `openssl rand -hex 32` in a terminal for the secret and fill it in the .env
3. Connect to the host using SSH with sudo permissions and run:
```
docker volume create searxng_searxng.etc && cd /var/lib/docker/volumes/searxng_searxng.etc/_data && wget -O settings.yml  https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/searxng/settings.yml
```
4. Optionally edit the file and add optional engines
5. Deploy the stack using Komodo

## Extra Search Engine options
 - [Astrophysics Data System (ADS)](https://ui.adsabs.harvard.edu/help/api/) - _[searxng](https://docs.searxng.org/dev/engines/online/astrophysics_data_system.html)_
 - [Core AC UK](https://core.ac.uk/services/api) - _[searxng](https://docs.searxng.org/dev/engines/online/core.html)_
