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

## Setup Action runner containers
1. Container 'runner' will be restarting regularly at this point.
2. On the host, run command [_source_](https://forgejo.org/docs/latest/admin/actions/configuration/):
   ```
   mkdir -p /opt/docker/forgejo/appdata/runner/data && \
   cd /opt/docker/forgejo/appdata/runner && \
   docker run --rm data.forgejo.org/forgejo/runner:12 \
   forgejo-runner generate-config > data/runner-config.yml
   chown user:user /opt/docker/forgejo/appdata -R && \
   chmod 775 /opt/docker/forgejo/appdata -R && \
   chmod 700 /opt/docker/forgejo/appdata/runner -R && \
   ```
3. Edit the new file
4. In Forgejo, login with an administrator account
   1. Navigate to the profile (top-right) and select 'Site administration'
   2. Go to 'Actions > Runners'
   3. Select 'Create new runner'
      - Give it a name
      - Copy everything from "forgejo:" to the end of the token. Example:
        ```
            forgejo:
              url: https://forgejo.alion.host/
              uuid: 8d845614-3b25-46d8-8817-0e3873010337
              token: af82655f1a13bbd4acc0b9aa7ff8452943f5f567
        ```
   4. Paste the connection into the end of the 'runner-config.yml' file. Make sure it sits in 'server connections'. Example:
      ```
      server:
        connections:
          forgejo:
            url: https://forgejo.alion.host/
            uuid: 8d845614-3b25-46d8-8817-0e3873010337
            token: af82655f1a13bbd4acc0b9aa7ff8452943f5f567
      ```
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
      - Enable: 'Skip local 2FA'
      - Additional Scopes: `email profile`
