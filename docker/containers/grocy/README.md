# Useful Information
## Default credentials
`admin/admin`
## Grocy Extensions
- [Grocy OAuth2 Middleware - Github](https://github.com/bboehmke/grocy-oauth)

# Manuals
## Installation
1. Run the following command to create the OAuth2 middleware file
   ```
   mkdir -p /opt/docker/grocy/appdata && cd /opt/docker/grocy/appdata && wget -O OAuthMiddleware.php https://raw.githubusercontent.com/bboehmke/grocy-oauth/refs/heads/master/OAuthMiddleware.php && chown -R komodo:komodo /opt/docker/grocy && chmod -R 700 /opt/docker/grocy && chmod 500 OAuthMiddleware.php
   ```
2. Login to Authentik as an admin user and go to 'Admin interface'
    1. Create an Application with Provider
        1. Name: Grocy
        2. UI Settings > Launch URL: `https://grocy.example.com`
    2. Next > 'Oauth2/OpenID Provider' > Next
    3. Configure Provider
        1. Authorization flow: '...implicit-consent'
        2. Client type: 'Confidential'
    4. Configure Bindigs
        1. Group: 'authentik-admin'
             - Order: `0`
        1. Group: 'access-grocy'
             - Order: `10`
