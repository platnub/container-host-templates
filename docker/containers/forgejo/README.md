# Requirements
 - [NFS Shares setup](https://github.com/platnub/container-host-templates/blob/main/virtual-machines/open-media-vault/README.md)

> [!NOTE]
> **Resource Requirements** [READ](../../../README.md#resource-requirements):
> - **Forgejo**
>    - limits:
>       - cpus: '2.00'
>       - memory: 2G
>    - reservations:
>       - cpus: '1.00'
>       - memory: 1G
> - **PostgresQL**
>    - limits:
>       - cpus: '2.00'
>       - memory: 2G
>    - reservations:
>       - cpus: '1.00'
>       - memory: 1G
>     
> ** Pangolin resource**
> - **Target**
>    - Protocol: 'http'
>    - Address: `forgejo`
>    - Port: `3000`

# Manuals

## Configuration
1. Deploy the stack in Komodo using the [compose.yml](compose.yml) and [.env](.env)
2. Setup the Pangolin resource
3. During the initial setup most can stay default
   - Administrator account settings
      - Administrator username: _<Same as Authentik admin (ahadmin)>_
      - Email: _<Same as Authentik admin (ahadmin)>_
       
## SSO Authentik setup [_source_](https://integrations.goauthentik.io/development/forgejo/)
1. Login to Authentik as administrator and open Admin interface
   -  Create Authentik Application with Provider
     - Name: `Forgejo`
     - Slug: `forgejo`
     - UI settings
       - Launch URL `https://forgejo..example.com`
   - Provider settings
     - Authorization flow: '...implicit-consent'
     - Client type: Confidential
     - Redirect URIs: Strict: https://forgejo.example.com/sso/OID/redirect/authentik
2. Setup Forgejo configuration
   1. Go to 'Site administration' using the administrator account from the profile in the top right
   2. Navigate to 'Idenity & access' > 'Authentication source'
   3. Select 'Add authentication source'
      - Athentication type: 'OAuth2'
      - Authentication name: `Authentik`
      - OAuth2 provider 'OpenID Connect'
      - Icon URL: `https://authentik.example.com/static/dist/assets/icons/icon.png`
      - OpenID Connect Auto Discovery URL: `https://authentik.example.com/application/o/forgejo/.well-known/openid-configuration`
      - Additional Scopes: `email profile`
