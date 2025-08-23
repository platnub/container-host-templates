#!/bin/sh
# Configure Grocy OAuth settings by replacing DefaultAuthMiddleware with OAuthMiddleware
# and inserting user-provided OAUTH_* settings.

set -eu

FILE="${1:-/var/lib/docker/volumes/grocy_config/_data/data/config.php}"
PAT="Setting('AUTH_CLASS', 'Grocy\Middleware\DefaultAuthMiddleware');"

if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE" >&2
  exit 1
fi

# Prevent accidental duplication if already using OAuth
if grep -Fq "Grocy\Middleware\OAuthMiddleware" "$FILE"; then
  echo "It appears $FILE already uses OAuthMiddleware. Aborting to avoid duplicate settings." >&2
  exit 1
fi

if ! grep -Fq "$PAT" "$FILE"; then
  echo "Could not find the exact line to replace in $FILE:" >&2
  echo "  $PAT" >&2
  exit 1
fi

echo "This will modify $FILE and create a timestamped backup."

# Prompts
printf "OAUTH_CLIENT_ID: "
IFS= read -r OAUTH_CLIENT_ID

# Hide input for secret when possible
if [ -t 0 ]; then
  printf "OAUTH_CLIENT_SECRET (input hidden): "
  stty -echo
  IFS= read -r OAUTH_CLIENT_SECRET
  stty echo
  printf "\n"
else
  printf "OAUTH_CLIENT_SECRET: "
  IFS= read -r OAUTH_CLIENT_SECRET
fi

DEFAULT_SCOPES="openid profile"
printf "OAUTH_SCOPES [%s]: " "$DEFAULT_SCOPES"
IFS= read -r OAUTH_SCOPES
[ -z "$OAUTH_SCOPES" ] && OAUTH_SCOPES="$DEFAULT_SCOPES"

DEFAULT_USERNAME_CLAIM="preferred_username"
printf "OAUTH_USERNAME_CLAIM [%s]: " "$DEFAULT_USERNAME_CLAIM"
IFS= read -r OAUTH_USERNAME_CLAIM
[ -z "$OAUTH_USERNAME_CLAIM" ] && OAUTH_USERNAME_CLAIM="$DEFAULT_USERNAME_CLAIM"

printf "OAUTH_AUTH_URL: "
IFS= read -r OAUTH_AUTH_URL
printf "OAUTH_TOKEN_URL: "
IFS= read -r OAUTH_TOKEN_URL
printf "OAUTH_USERINFO_URL: "
IFS= read -r OAUTH_USERINFO_URL

# Escape for PHP single-quoted strings: escape ' and \ as \' and \\
escape_php() {
  printf "%s" "$1" | sed "s/['\\\\]/\\\\&/g"
}

CID=$(escape_php "$OAUTH_CLIENT_ID")
CSECRET=$(escape_php "$OAUTH_CLIENT_SECRET")
SCOPES=$(escape_php "$OAUTH_SCOPES")
UN=$(escape_php "$OAUTH_USERNAME_CLAIM")
AUTH_URL=$(escape_php "$OAUTH_AUTH_URL")
TOKEN_URL=$(escape_php "$OAUTH_TOKEN_URL")
USERINFO_URL=$(escape_php "$OAUTH_USERINFO_URL")

BLOCK=$(cat <<EOF
Setting('AUTH_CLASS', 'Grocy\Middleware\OAuthMiddleware');
// Options when using OAuthMiddleware
Setting('OAUTH_CLIENT_ID', '$CID');
Setting('OAUTH_CLIENT_SECRET', '$CSECRET');
Setting('OAUTH_SCOPES', '$SCOPES');
Setting('OAUTH_USERNAME_CLAIM', '$UN');
Setting('OAUTH_AUTH_URL', '$AUTH_URL');
Setting('OAUTH_TOKEN_URL', '$TOKEN_URL');
Setting('OAUTH_USERINFO_URL', '$USERINFO_URL');
EOF
)

# Backup
BACKUP="$FILE.bak.$(date +%Y%m%d%H%M%S)"
cp "$FILE" "$BACKUP"

# Replace the target line with the new block
awk -v pat="$PAT" -v repl="$BLOCK" '
  replaced==0 && index($0, pat) { print repl; replaced=1; next }
  { print }
' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

echo "Updated $FILE"
echo "Backup saved as $BACKUP"
