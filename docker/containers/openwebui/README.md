# Pangolin Resource configuration
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `openwebui`
    - Port: `8080`
- Authentication
  - Use Platform SSO: Disabled

# Extra
 - [Google provider - OpenWebUI Pipeline](https://github.com/open-webui/pipelines/blob/main/examples/pipelines/providers/google_manifold_pipeline.py)

# Manuals
## Pangolin Resource configuration
- Proxy
  - Target
    - Method: 'http'
    - IP / Hostname: `openwebui`
    - Port: `8080`
- Authentication
  - Use Platform SSO: Disabled

## Installation
1. Create stack in Komodo using [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/openwebui/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/openwebui/.env)
2. Deploy the stack using Komodo

## SSO Setup
1. Create stack in Komodo using [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/openwebui/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/openwebui/.env)
2. Follow the instructions from [Authentik - OpenWebUI integration](https://integrations.goauthentik.io/miscellaneous/open-webui/)
    1. Login to Authentik as administrator and open 'Admin interface'
        1. Create Application with Provider
            1. Application
                1. Name: `OpenWebUI`
                2. Slug: `openwebui`
                3. UI Settings > Launch URL: `https://openwebui.example.com`
            2. Provider
                1. Type: 'OAuth2/OpenID Provider'
                2. Authorization flow: '...implicit-consent'
                3. Client type: Confidential
                4. Redirect URIs: Strict: `https://openwebui.example.com/oauth/oidc/callback`
    2. Modify .env file with variables and change the domain
        1. OAUTH_CLIENT_ID
        2. OAUTH_CLIENT_SECRET
        3. OPENID_PROVIDER_URL: https://authentik.example.com/application/o/openwebui/.well-known/openid-configuration
        4. OPENID_REDIRECT_URI: https://openwebui.example.com/oauth/oidc/callback
3. Deploy the container through Komodo
4. Make sure that the 'SearXNG Query URL' is set to `http://searxng:8080/search?q=<query>` under 'Admin Panel > Settings > Web Search'
