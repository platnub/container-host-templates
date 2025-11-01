# Useful information
## Discord packages
- [NCNodes- Community built nodes for n8n](https://ncnodes.com)
    - [discord-trigger](https://ncnodes.com/package/n8n-nodes-discord-trigger)

# Manuals
## Pangolin Resource configuration
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `n8n`
    - Port: `5678`
- Authentication
  - Use Platform SSO: Disabled

## Setup
1. Deploy container using the [compose.yml] and [.env] files in Komodo
2. Create the Pangolin tunnel and connect using https://n8n.example.com
3. Create an admin account
4. Optionally setup a license key
     - 'Settings > Usage plan'
