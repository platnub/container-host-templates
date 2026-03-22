> [!NOTE]
> **Resource Requirements** [READ](../../../README.md#resource-requirements):
> - **Actual Finance** (each)
>    - limits:
>       - cpus: '1.00'
>       - memory: 1G
>    - reservations:
>       - cpus: '0.10'
>       - memory: 50M

# Manuals
## Installation
1. For each induvidual instance, add an extra volume and replace <name> with a unique identifier.
2. Deploy and the stack in Komodo using the [compose.yml](compose.yml) and [.env](.env)
