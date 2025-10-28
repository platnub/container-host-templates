# Manuals

## Installation
> [!IMPORTANT]
> The [compose.yml](https://github.com/supabase/supabase/blob/master/docker/docker-compose.yml) and [.env](https://github.com/supabase/supabase/blob/master/docker/.env.example) are based off of the Supabase Github examples and can change at any time.

1. Create the stack in Komodo using the [compose.yml](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/supabase/compose.yml) and [.env](https://raw.githubusercontent.com/platnub/container-host-templates/refs/heads/main/docker/containers/supabase/.env) files.
2. Following the instructions from the [Supabase docs](https://supabase.com/docs/guides/self-hosting/docker#securing-your-services), generate the keys:
    1. Go to the [Supabase docs - Securing your services](https://supabase.com/docs/guides/self-hosting/docker#securing-your-services) and save the generated JWT
    2. Generate a 'POSTGRES_PASSWORD', 'PG_META_CRYPTO_KEY', 'SECRKET_KEY_BASE', 'VAULT_ENC_KEY' and a 'PG_META_CRYPTO_KEY' using `openssl rand -base64 48` in a terminal
    3. Create a 'POOLER_TENANT_ID', optionally using [randomwordgenerator.com](https://randomwordgenerator.com/). Example, 3 words: `finger-long-access`
    4. Configure
         - SITE_URL: https://supabase.example.com
         - SMTP_HOST: 
