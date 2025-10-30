# Manuals

## Installation
> [!IMPORTANT]
> 1. The [compose.yml](https://github.com/supabase/supabase/blob/master/docker/docker-compose.yml) and [.env](https://github.com/supabase/supabase/blob/master/docker/.env.example) are based off of the Supabase Github examples and can change at any time.
> 2. [Temporary fix](https://github.com/supabase/supabase/issues/39933) by changing the Analytics container logflare container image to [1.15.3](https://github.com/Logflare/logflare/releases/tag/v1.15.3). Something seems to change processor related in [1.15.4](https://github.com/Logflare/logflare/releases/tag/v1.15.4)
> 3. [Temporary fix](https://github.com/orgs/supabase/discussions/26362) is to manually create the volume files
> 4. Added network `default` and `supabase` to the Kong container and close port 8000 and 8443

1. Create the stack in Komodo using the [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/supabase/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/supabase/.env) files.
2. Following the instructions from the [Supabase docs](https://supabase.com/docs/guides/self-hosting/docker#securing-your-services), generate the keys:
    1. Go to the [Supabase docs - Securing your services](https://supabase.com/docs/guides/self-hosting/docker#securing-your-services) and save the generated JWT
    2. Generate a 'POSTGRES_PASSWORD', 'PG_META_CRYPTO_KEY', 'SECRKET_KEY_BASE' and a 'PG_META_CRYPTO_KEY' using `openssl rand -base64 48` in a terminal
    3. Generate a 'VAULT_ENC_KEY' using `openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c32; echo` in a terminal
    4. Create a 'POOLER_TENANT_ID', optionally using [randomwordgenerator.com](https://randomwordgenerator.com/). Example, 3 words: `finger-long-access`
    5. Configure
         - SITE_URL: https://supabase.example.com
         - SMTP_HOST:
3. Connect to the host using SSH with sudo access and run
   ```mkdir -p /opt/docker/supabase/volumes/api && cd /opt/docker/supabase/volumes/api && wget -O kong.yml https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/api/kong.yml && mkdir /opt/docker/supabase/volumes/db && cd /opt/docker/supabase/volumes/db && wget -O _supabase.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/_supabase.sql && wget -O jwt.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/jwt.sql && wget -O logs.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/logs.sql && wget -O pooler.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/pooler.sql && wget -O realtime.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/realtime.sql && wget -O roles.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/roles.sql && wget -O webhooks.sql https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/db/webhooks.sql && mkdir -p /opt/docker/supabase/volumes/functions/hello && cd /opt/docker/supabase/volumes/functions/hello && wget -O index.ts https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/functions/hello/index.ts && mkdir /opt/docker/supabase/volumes/functions/main && cd /opt/docker/supabase/volumes/functions/main && wget -O index.ts https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/functions/main/index.ts && mkdir -p /opt/docker/supabase/volumes/logs && cd /opt/docker/supabase/volumes/logs && wget -O vector.yml https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/logs/vector.yml && mkdir /opt/docker/supabase/volumes/pooler && cd /opt/docker/supabase/volumes/pooler && wget -O pooler.exs https://raw.githubusercontent.com/supabase/supabase/refs/heads/master/docker/volumes/pooler/pooler.exs && chown komodo:komodo /opt/docker/supabase && chmod 700 /opt/docker/supabase```
4. Deploy the stack using Komodo
