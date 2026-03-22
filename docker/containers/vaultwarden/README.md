> [!NOTE]
> **Resource Requirements** [READ](../../../README.md#resource-requirements):
> - **Vaultwarden**
>    - limits:
>       - cpus: '2.00'
>       - memory: 1.5G
>    - reservations:
>       - cpus: '0.50'
>       - memory: 500M

# Pangolin Resource configuration
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `vaultwarden`
    - Port: `80`
- Authentication
  - Use Platform SSO: Enabled
- Rules
  - Priority: `1`
    - Action: 'Pass to Auth'
    - Match Type: 'Path'
    - Value: `/admin/*`
  - Priority: `2`
    - Action: 'Always Allow'
    - Match Type: 'Path'
    - Value: `/*`
