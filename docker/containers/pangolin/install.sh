#!/usr/bin/env bash
#
# Pangolin VM preparation + Komodo Periphery installer
#
# Prepares a fresh Debian VM: hostname, timezone, SSH hardening, UFW,
# Docker and Komodo Periphery.
#
# Docker runs as the normal rootful daemon. Periphery runs as a systemd
# *user* service owned by the unprivileged 'dockerd' account, which is a
# member of the 'docker' group. Note that docker group membership is
# root-equivalent on this host.
#
# Usage:  sudo ./pangolin-setup.sh
#
set -uo pipefail

# ---------------------------------------------------------------------------
# Presentation helpers
# ---------------------------------------------------------------------------

if [[ -t 1 ]]; then
    BOLD=$'\e[1m'; DIM=$'\e[2m'; RED=$'\e[31m'; GREEN=$'\e[32m'
    YELLOW=$'\e[33m'; CYAN=$'\e[36m'; RESET=$'\e[0m'
    IS_TTY=1
else
    BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
    IS_TTY=0
fi

TOTAL_STEPS=21
STEP=0
TAIL_KEEP=30           # lines of output kept in memory per step, shown on failure

rule()     { printf '%s%s%s\n' "$DIM" "──────────────────────────────────────────────────────────────" "$RESET"; }
section()  { printf '\n%s%s%s\n' "${BOLD}${CYAN}" "$1" "$RESET"; }
info()     { printf '  %s\n' "$1"; }
note()     { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn()     { printf '  %s! %s%s\n' "$YELLOW" "$1" "$RESET"; }
die()      { printf '\n%sERROR:%s %s\n\n' "${RED}${BOLD}" "$RESET" "$1" >&2; exit 1; }

_step_start() {
    STEP=$((STEP + 1))
    printf '  %-56s' "$(printf '[%02d/%02d] %s' "$STEP" "$TOTAL_STEPS" "$1")"
}

# _step_end <exit code> <description> <output lines...>
_step_end() {
    local rc=$1 desc=$2; shift 2
    if (( rc == 0 )); then
        printf '%sok%s\n' "$GREEN" "$RESET"
        return
    fi
    printf '%sFAILED%s\n' "$RED" "$RESET"
    printf '\n  %sStep "%s" exited with status %s.%s\n' "$RED" "$desc" "$rc" "$RESET" >&2
    if (( $# > 0 )); then
        printf '  %sLast %s lines of output:%s\n\n' "$DIM" "$#" "$RESET" >&2
        printf '    %s\n' "$@" >&2
    else
        printf '  %sThe command produced no output.%s\n' "$DIM" "$RESET" >&2
    fi
    die "Aborting. Nothing after this step was executed."
}

# run <description> <command...>
# Output is buffered in memory and discarded on success, printed on failure.
run() {
    local desc="$1"; shift
    _step_start "$desc"

    local rc=0 line fd wfd
    local -a buf=()

    if (( IS_TTY )); then
        coproc CMD { "$@" </dev/null 2>&1; }
        local pid=$CMD_PID
        # Duplicate the pipe so the buffer survives bash reaping the coprocess
        exec {fd}<&"${CMD[0]}"
        exec {wfd}>&"${CMD[1]}"; exec {wfd}>&-

        local i=0 chars='|/-\'
        printf ' '
        while kill -0 "$pid" 2>/dev/null; do
            if IFS= read -r -t 0.2 -u "$fd" line; then
                buf+=("$line")
                (( ${#buf[@]} > TAIL_KEEP )) && buf=("${buf[@]: -TAIL_KEEP}")
            else
                printf '\b%s' "${chars:i++%4:1}"
            fi
        done
        while IFS= read -r -t 0.2 -u "$fd" line; do
            buf+=("$line")
            (( ${#buf[@]} > TAIL_KEEP )) && buf=("${buf[@]: -TAIL_KEEP}")
        done
        printf '\b'
        wait "$pid" || rc=$?
        exec {fd}<&-
    else
        local out
        out="$( "$@" </dev/null 2>&1 )" || rc=$?
        [[ -n "$out" ]] && mapfile -t buf <<<"$out"
        (( ${#buf[@]} > TAIL_KEEP )) && buf=("${buf[@]: -TAIL_KEEP}")
    fi

    _step_end "$rc" "$desc" ${buf[@]+"${buf[@]}"}
}

# run_fg <description> <command...>
# Same contract, but keeps the controlling terminal (needed for machinectl).
run_fg() {
    local desc="$1"; shift
    _step_start "$desc"

    local rc=0 out
    local -a buf=()
    out="$( "$@" 2>&1 )" || rc=$?
    [[ -n "$out" ]] && mapfile -t buf <<<"$out"
    (( ${#buf[@]} > TAIL_KEEP )) && buf=("${buf[@]: -TAIL_KEEP}")

    _step_end "$rc" "$desc" ${buf[@]+"${buf[@]}"}
}

# ---------------------------------------------------------------------------
# Input helpers
# ---------------------------------------------------------------------------

RESERVED_PORTS=(80 443 51820)

random_port() {
    if command -v shuf >/dev/null 2>&1; then
        shuf -i 1024-65535 -n 1
    else
        echo $(( ((RANDOM << 15 | RANDOM) % 64512) + 1024 ))
    fi
}

port_in_use() {
    local p="$1" r
    for r in "${RESERVED_PORTS[@]}"; do
        [[ "$p" == "$r" ]] && return 0
    done
    return 1
}

# Escape a string so it is safe as a sed replacement (delimiter '|')
sed_escape() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

ask_timezone() {
    local tz
    info "Which timezone should this machine use?"
    note "Format: Region/City   Example: Europe/Amsterdam"
    while :; do
        read -rp "  Timezone: " tz
        tz="$(printf '%s' "$tz" | tr -d '[:space:]')"
        if [[ -z "$tz" ]]; then
            warn "A timezone is required."
            continue
        fi
        if [[ -f "/usr/share/zoneinfo/$tz" ]]; then
            TIMEZONE="$tz"
            return
        fi
        warn "Unknown timezone '$tz'. Try something like Europe/Amsterdam or America/New_York."
    done
}

# ask_port <prompt> <variable name>
ask_port() {
    local prompt="$1" varname="$2" val
    while :; do
        read -rp "  $prompt: " val
        val="$(printf '%s' "$val" | tr -d '[:space:]')"

        if [[ -z "$val" ]]; then
            val="$(random_port)"
            while port_in_use "$val"; do val="$(random_port)"; done
            printf '\n  %sGenerated port: %s%s%s\n' "$YELLOW" "$BOLD" "$val" "$RESET"
            note "Write this down, you will need it to reach this machine."
            printf '  Press %sEnter%s to continue... ' "$BOLD" "$RESET"
            read -r _
            printf '\n'
            RESERVED_PORTS+=("$val")
            printf -v "$varname" '%s' "$val"
            return
        fi

        if [[ ! "$val" =~ ^[0-9]+$ ]]; then
            warn "Ports are numeric only."
            continue
        fi
        if (( val < 1024 || val > 65535 )); then
            warn "Pick a port between 1024 and 65535."
            continue
        fi
        if port_in_use "$val"; then
            warn "Port $val is already taken by another rule in this setup (80, 443, 51820 or the other service)."
            continue
        fi

        RESERVED_PORTS+=("$val")
        printf -v "$varname" '%s' "$val"
        return
    done
}

ask_max_auth_tries() {
    local val
    info "Set SSH MaxAuthTries (limits failed authentication attempts per connection)"
    printf '\n'
    note "Default: 6 (recommended)"
    note "Increase if you use multiple SSH keys"
    printf '\n'
    while :; do
        read -rp "  MaxAuthTries [6]: " val
        val="$(printf '%s' "$val" | tr -d '[:space:]')"
        [[ -z "$val" ]] && val=6
        if [[ ! "$val" =~ ^[0-9]+$ ]] || (( val < 1 || val > 100 )); then
            warn "Enter a whole number between 1 and 100."
            continue
        fi
        MAX_AUTH_TRIES="$val"
        return
    done
}

ask_password() {
    local p1 p2
    info "Password for the 'pangolin' user (this becomes your login account)."
    note "Input is hidden."
    while :; do
        read -rsp "  Password: " p1; printf '\n'
        if [[ -z "$p1" ]]; then
            warn "Password cannot be empty."
            continue
        fi
        if (( ${#p1} < 8 )); then
            warn "That is shorter than 8 characters. Consider something longer."
        fi
        read -rsp "  Repeat password: " p2; printf '\n'
        if [[ "$p1" != "$p2" ]]; then
            warn "Passwords do not match. Try again."
            continue
        fi
        PANGOLIN_PASSWORD="$p1"
        return
    done
}

ask_core_address() {
    local val host port
    info "Address of your Komodo Core."
    note "Must start with https:// and must include the port Core listens on."
    note "Example: https://komodo.example.com:9120  or  https://203.0.113.10:9120"
    while :; do
        read -rp "  Core address: " val
        val="$(printf '%s' "$val" | tr -d '[:space:]')"
        val="${val%/}"                                  # drop a trailing slash

        if [[ -z "$val" ]]; then
            warn "The Core address is required."
            continue
        fi
        if [[ "$val" == http://* ]]; then
            warn "Plain http:// would send the onboarding key in the clear. Use https://."
            continue
        fi
        if [[ "$val" != https://* ]]; then
            warn "The address must start with https://"
            continue
        fi
        if [[ ! "$val" =~ ^https://[A-Za-z0-9._-]+:[0-9]{1,5}$ ]]; then
            warn "Include the port, with no path after it. Example: https://komodo.example.com:9120"
            continue
        fi

        port="${val##*:}"
        if (( port < 1 || port > 65535 )); then
            warn "Port $port is out of range (1-65535)."
            continue
        fi

        host="${val#https://}"; host="${host%:*}"
        if [[ "$host" == "<core-address>" || "$host" == *example.com ]]; then
            warn "That is still the placeholder. Enter your real Core hostname."
            continue
        fi

        CORE_ADDRESS="$val"
        return
    done
}

ask_onboarding_key() {
    local val
    info "Komodo onboarding key."
    note "Generate one in Komodo Core under Server settings. It lets this machine"
    note "register itself with Core the first time it connects."
    while :; do
        read -rp "  Onboarding key: " val
        val="$(printf '%s' "$val" | tr -d '[:space:]')"
        if [[ -z "$val" ]]; then
            warn "The onboarding key cannot be empty."
            continue
        fi
        if [[ "$val" == *'"'* ]]; then
            warn "The onboarding key cannot contain a double quote character."
            continue
        fi
        ONBOARDING_KEY="$val"
        return
    done
}

ask_allowed_ips() {
    local raw ip ok
    info "Which IP addresses may talk to Periphery?"
    note "This is the IP of your Komodo Core (its WAN IP when Core runs behind Pangolin)."
    note "Single address or CIDR. Separate multiple entries with a comma or space."
    note "Example: 203.0.113.10  or  203.0.113.0/24, 198.51.100.7"
    while :; do
        read -rp "  Allowed IPs: " raw
        if [[ -z "${raw// /}" ]]; then
            warn "At least one address is required."
            continue
        fi
        ok=1
        ALLOWED_IPS_LIST=()
        for ip in ${raw//,/ }; do
            if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$ ]]; then
                ALLOWED_IPS_LIST+=("$ip")
            else
                warn "'$ip' is not a valid IPv4 address or CIDR range."
                ok=0
            fi
        done
        (( ok )) && (( ${#ALLOWED_IPS_LIST[@]} > 0 )) && break
    done

    ALLOWED_IPS_TOML=""
    for ip in "${ALLOWED_IPS_LIST[@]}"; do
        [[ -n "$ALLOWED_IPS_TOML" ]] && ALLOWED_IPS_TOML+=", "
        ALLOWED_IPS_TOML+="\"$ip\""
    done
}

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------

task_hostname() {
    hostnamectl set-hostname pangolin
}

task_timezone() {
    timedatectl set-timezone "$TIMEZONE"
}

task_apt_update() {
    apt-get update -y
}

task_apt_upgrade() {
    apt-get -y \
        -o Dpkg::Options::=--force-confdef \
        -o Dpkg::Options::=--force-confold \
        upgrade
}

task_base_packages() {
    # python3 is required by the Komodo setup-periphery script further down
    apt-get install -y ssh fail2ban ufw systemd-container python3
}

task_ssh_config() {
    sed -i 's/^#*\s*Port .*/Port '"$SSH_PORT"'/' /etc/ssh/sshd_config
    sed -i 's/^#*\s*MaxAuthTries .*/MaxAuthTries '"$MAX_AUTH_TRIES"'/' /etc/ssh/sshd_config
    sed -i 's/^#*\s*MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config
    # sed -i 's/^#*\s*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#*\s*AllowTcpForwarding .*/AllowTcpForwarding No/' /etc/ssh/sshd_config
}

task_ssh_restart() {
    systemctl daemon-reload
    systemctl restart sshd
}

task_disable_ipv6() {
    printf '\n# Disabling the IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\n' \
        | tee -a /etc/sysctl.conf > /dev/null
    sysctl -p
    sed -i 's|^#*\s*IPV6=.*|IPV6=no|' /etc/default/ufw
}

task_ufw_rules() {
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow "$SSH_PORT"/tcp
    ufw allow "$KOMODO_PORT"/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 51820/udp
    ufw allow 21820/udp
}

task_ufw_enable() {
    ufw --force enable
}

task_docker_repo() {
    apt-get install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null
}

task_docker_install() {
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

task_user_pangolin() {
    useradd -r pangolin
    usermod -aG sudo pangolin
}

task_password_and_lock_root() {
    yes "$PANGOLIN_PASSWORD" | passwd pangolin
    passwd -l root
}

task_users() {
    groupadd -g 1337 dockerd
    useradd --create-home dockerd -u 1337 -g 1337
    loginctl enable-linger dockerd
    groupadd -g 1001 bkup
    adduser --gecos GECOS --disabled-password --uid 1001 --gid 1001 bkup
    mkdir -p /opt/docker
    chown dockerd:dockerd /opt/docker
    chmod 700 /opt/docker
    usermod -aG docker dockerd
}

task_download_config() {
    mkdir -p /home/dockerd/.config/komodo
    curl -fsSL -o /home/dockerd/.config/komodo/periphery.config.toml \
        https://raw.githubusercontent.com/moghtech/komodo/refs/heads/main/config/periphery.config.toml
}

task_configure_periphery() {
    local cfg="/home/dockerd/.config/komodo/periphery.config.toml"
    local ips
    ips="$(sed_escape "$ALLOWED_IPS_TOML")"

    # Match on the key only, whether or not the line is commented out, and
    # replace the whole line. Same shape as the sshd_config edits above.
    sed -i 's|^#*\s*port\s*=.*|port = '"$KOMODO_PORT"'|' "$cfg"
    sed -i 's|^#*\s*root_directory\s*=.*|root_directory = "/home/dockerd/periphery"|' "$cfg"
    sed -i 's|^#*\s*stack_dir\s*=.*|stack_dir = "/opt/docker"|' "$cfg"
    sed -i 's|^#*\s*allowed_ips\s*=.*|allowed_ips = ['"$ips"']|' "$cfg"

    # A sed that matches nothing still exits 0. An empty allowed_ips means
    # "allow everyone" and a wrong port means Core cannot reach us, so confirm
    # both landed rather than trusting the substitutions.
    if ! grep -qF "${ALLOWED_IPS_LIST[0]}" "$cfg"; then
        echo "allowed_ips was not written to $cfg - the upstream template has changed." >&2
        return 1
    fi
    if ! grep -qE "^port = ${KOMODO_PORT}\b" "$cfg"; then
        echo "port was not written to $cfg - the upstream template has changed." >&2
        return 1
    fi
}

task_permissions() {
    chown -R dockerd:dockerd /home/dockerd
    chmod -R 700 /home/dockerd/.config/komodo
    chmod -R 600 /home/dockerd/.config/komodo/periphery.config.toml
}

task_install_periphery() {
    # The arguments after the -c string are the shell's positional parameters:
    # 'sh' becomes $0, then the three values become $1..$3. They must be read
    # from inside the command string, otherwise they are silently discarded.
    machinectl shell dockerd@ /bin/sh -c '
        curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py \
          | python3 - --user \
              --core-address="$1" \
              --connect-as="$2" \
              --onboarding-key="$3"
    ' sh "$CORE_ADDRESS" "$(hostname)" "$ONBOARDING_KEY"
    chown -R dockerd:dockerd /home/dockerd
}

task_enable_periphery() {
    systemctl --user -M dockerd@ enable periphery
    loginctl enable-linger dockerd
}

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------

clear 2>/dev/null || true
printf '\n%s%s%s\n' "${BOLD}${CYAN}" "  Pangolin VM setup + Komodo Periphery" "$RESET"
note "  Hardened Debian host with Docker and Komodo Periphery"
printf '\n'
rule

[[ $EUID -eq 0 ]] || die "This script must be run as root (try: sudo $0)."

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID:-}" != "debian" ]]; then
        warn "This script targets Debian; detected '${PRETTY_NAME:-unknown}'."
        warn "The Docker repository step assumes Debian and may fail."
        printf '\n'
    fi
fi

# ---------------------------------------------------------------------------
# Questions
# ---------------------------------------------------------------------------

section "Step 1 of 8  ·  Timezone"
ask_timezone

section "Step 2 of 8  ·  SSH port"
info "Which port should SSH listen on?"
note "Leave empty to generate a random port between 1024 and 65535."
ask_port "SSH port [random]" SSH_PORT

section "Step 3 of 8  ·  Komodo Periphery port"
info "Which port should Komodo Periphery listen on?"
note "Komodo's default is 8120. Leave empty to generate a random port between 1024 and 65535."
ask_port "Komodo port [random]" KOMODO_PORT

section "Step 4 of 8  ·  SSH authentication attempts"
ask_max_auth_tries

section "Step 5 of 8  ·  Pangolin user password"
ask_password

section "Step 6 of 8  ·  Komodo Core address"
ask_core_address

section "Step 7 of 8  ·  Komodo onboarding key"
ask_onboarding_key

section "Step 8 of 8  ·  Allowed IPs"
ask_allowed_ips

# ---------------------------------------------------------------------------
# Summary & confirmation
# ---------------------------------------------------------------------------

printf '\n'
rule
section "Review"
printf '  %-22s %s\n' "Hostname:"        "pangolin"
printf '  %-22s %s\n' "Timezone:"        "$TIMEZONE"
printf '  %-22s %s%s%s\n' "SSH port:"    "$BOLD" "$SSH_PORT" "$RESET"
printf '  %-22s %s%s%s\n' "Komodo port:" "$BOLD" "$KOMODO_PORT" "$RESET"
printf '  %-22s %s\n' "MaxAuthTries:"    "$MAX_AUTH_TRIES"
printf '  %-22s %s\n' "Pangolin password:" "$(printf '%*s' "${#PANGOLIN_PASSWORD}" '' | tr ' ' '*')"
printf '  %-22s %s\n' "Core address:"    "$CORE_ADDRESS"
printf '  %-22s %s\n' "Onboarding key:"   "$ONBOARDING_KEY"
printf '  %-22s %s\n' "Allowed IPs:"     "${ALLOWED_IPS_LIST[*]}"
printf '\n'
warn "The root account will be locked and SSH will move to port $SSH_PORT."
warn "Keep your current session open until you have verified the new login works."
printf '\n'
read -rp "  Start the installation? [y/N]: " confirm
[[ "${confirm,,}" == "y" || "${confirm,,}" == "yes" ]] || die "Cancelled. Nothing was changed."

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# ---------------------------------------------------------------------------
# Execution
# ---------------------------------------------------------------------------

section "System basics"
run "Setting hostname to 'pangolin'"        task_hostname
run "Setting timezone to $TIMEZONE"         task_timezone
run "Refreshing package lists"              task_apt_update
run "Upgrading installed packages"          task_apt_upgrade
run "Installing base packages"              task_base_packages

section "SSH hardening"
run "Applying SSH configuration"            task_ssh_config
run "Restarting the SSH service"            task_ssh_restart

effective_port="$(sshd -T 2>/dev/null | awk '/^port /{print $2; exit}')"
if [[ -n "$effective_port" && "$effective_port" != "$SSH_PORT" ]]; then
    warn "sshd reports port $effective_port, not $SSH_PORT."
    warn "A drop-in file in /etc/ssh/sshd_config.d/ is probably overriding it."
fi

section "Network and firewall"
run "Disabling IPv6"                        task_disable_ipv6
run "Adding firewall rules"                 task_ufw_rules
run "Enabling the firewall"                 task_ufw_enable

section "Docker"
run "Adding the Docker repository"          task_docker_repo
run "Refreshing package lists"              task_apt_update
run "Installing Docker Engine"              task_docker_install

section "Users and directories"
run "Creating the 'pangolin' user"          task_user_pangolin
run "Setting password, locking root"        task_password_and_lock_root
run "Creating 'dockerd' user and /opt/docker" task_users

section "Komodo Periphery"
run "Downloading the Periphery config"      task_download_config
run "Applying your Periphery settings"      task_configure_periphery

run "Tightening file permissions"           task_permissions
run_fg "Installing Komodo Periphery"        task_install_periphery
run "Enabling the Periphery service"        task_enable_periphery

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

server_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
[[ -z "$server_ip" ]] && server_ip="<this-server-ip>"

printf '\n'
rule
printf '\n%s%s%s\n\n' "${BOLD}${GREEN}" "  Setup complete." "$RESET"

info "Log in from now on with:"
printf '      %sssh pangolin@%s -p %s%s\n\n' "$BOLD" "$server_ip" "$SSH_PORT" "$RESET"

info "This machine registers itself with Core at:"
printf '      %s%s%s\n\n' "$BOLD" "$CORE_ADDRESS" "$RESET"

info "If it does not appear automatically, add it in Komodo Core as:"
printf '      %shttps://%s:%s%s\n\n' "$BOLD" "$server_ip" "$KOMODO_PORT" "$RESET"

info "Open ports:  $SSH_PORT/tcp (ssh)  80/tcp  443/tcp  51820/udp (wireguard)  $KOMODO_PORT/tcp (komodo)"
printf '\n'
warn "The root account is locked. Verify the pangolin login in a second"
warn "terminal before closing this session."
printf '\n'
note "  A reboot is recommended to make sure every change is active."
printf '\n'
