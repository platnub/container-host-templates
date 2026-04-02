#!/usr/bin/env bash

#
# Copyright (c) 2021-2026 community-scripts ORG
# Author: thost96 (thost96) | michelroegl-brunner | MickLesk
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE

# ==============================================================================
# Docker VM - Creates a Docker-ready Virtual Machine
# ==============================================================================

source <(curl -fsSL https://git.community-scripts.org/community-scripts/ProxmoxVE/raw/branch/main/misc/api.func) 2>/dev/null
source <(curl -fsSL https://git.community-scripts.org/community-scripts/ProxmoxVE/raw/branch/main/misc/vm-core.func) 2>/dev/null
source <(curl -fsSL https://git.community-scripts.org/community-scripts/ProxmoxVE/raw/branch/main/misc/cloud-init.func) 2>/dev/null || true
load_functions
# ==============================================================================
# SCRIPT VARIABLES
# ==============================================================================
APP="Docker"
APP_TYPE="vm"
NSAPP="docker-vm"
var_os="debian"
var_version="13"

GEN_MAC=02:$(openssl rand -hex 5 | awk '{print toupper($0)}' | sed 's/\(..\)/\1:/g; s/.$//')
RANDOM_UUID="$(cat /proc/sys/kernel/random/uuid)"
METHOD=""
DISK_SIZE="10G"
USE_CLOUD_INIT="no"
OS_TYPE=""
OS_VERSION=""
THIN="discard=on,ssd=1,"
GENERATED_PASSWORD=""

function header_info() {
  clear
  cat <<"EOF"
 /$$$$$$$                      /$$                                 /$$   /$$                       /$$    
| $$__  $$                    | $$                                | $$  | $$                      | $$    
| $$  \ $$  /$$$$$$   /$$$$$$$| $$   /$$  /$$$$$$   /$$$$$$       | $$  | $$  /$$$$$$   /$$$$$$$ /$$$$$$  
| $$  | $$ /$$__  $$ /$$_____/| $$  /$$/ /$$__  $$ /$$__  $$      | $$$$$$$$ /$$__  $$ /$$_____/|_  $$_/  
| $$  | $$| $$  \ $$| $$      | $$$$$$/ | $$$$$$$$| $$  \__/      | $$__  $$| $$  \ $$|  $$$$$$   | $$    
| $$  | $$| $$  | $$| $$      | $$_  $$ | $$_____/| $$            | $$  | $$| $$  | $$ \____  $$  | $$ /$$
| $$$$$$$/|  $$$$$$/|  $$$$$$$| $$ \  $$|  $$$$$$$| $$            | $$  | $$|  $$$$$$/ /$$$$$$$/  |  $$$$/
|_______/  \______/  \_______/|__/  \__/ \_______/|__/            |__/  |__/ \______/ |_______/    \___/
 _    _            _      _                                                 
| |  | |          | |    (_)                                                
| |  | | ___  _ __| | __  _ _ __    _ __  _ __ ___   __ _ _ __ ___  ___ ___ 
| |/\| |/ _ \| '__| |/ / | | '_ \  | '_ \| '__/ _ \ / _` | '__/ _ \/ __/ __|
\  /\  / (_) | |  |   <  | | | | | | |_) | | | (_) | (_| | | |  __/\__ \__ \
 \/  \/ \___/|_|  |_|\_\ |_|_| |_| | .__/|_|  \___/ \__, |_|  \___||___/___/
                                   | |               __/ |                  
                                   |_|              |___/                   
EOF
}
header_info
echo -e "\n Loading..."
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
BGN=$(echo "\033[4;92m")
GN=$(echo "\033[1;92m")
DGN=$(echo "\033[32m")
CL=$(echo "\033[m")
CL=$(echo "\033[m")
BOLD=$(echo "\033[1m")
BFR="\\r\\033[K"
HOLD=" "
TAB="  "
CM="${TAB}✔️${TAB}${CL}"
CROSS="${TAB}✖️${TAB}${CL}"
INFO="${TAB}💡${TAB}${CL}"
OS="${TAB}🖥️${TAB}${CL}"
CONTAINERTYPE="${TAB}📦${TAB}${CL}"
DISKSIZE="${TAB}💾${TAB}${CL}"
CPUCORE="${TAB}🧠${TAB}${CL}"
RAMSIZE="${TAB}🛠️${TAB}${CL}"
CONTAINERID="${TAB}🆔${TAB}${CL}"
HOSTNAME="${TAB}🏠${TAB}${CL}"
BRIDGE="${TAB}🌉${TAB}${CL}"
GATEWAY="${TAB}🌐${TAB}${CL}"
DEFAULT="${TAB}⚙️${TAB}${CL}"
MACADDRESS="${TAB}🔗${TAB}${CL}"
VLANTAG="${TAB}🏷️${TAB}${CL}"
CREATING="${TAB}🚀${TAB}${CL}"
ADVANCED="${TAB}🧩${TAB}${CL}"
CLOUD="${TAB}☁️${TAB}${CL}"

# ==============================================================================
# ERROR HANDLING & CLEANUP
# ==============================================================================
set -e
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
trap cleanup EXIT
trap 'post_update_to_api "failed" "130"' SIGINT
trap 'post_update_to_api "failed" "143"' SIGTERM
trap 'post_update_to_api "failed" "129"; exit 129' SIGHUP
function error_handler() {
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
  post_update_to_api "failed" "${exit_code}"
  echo -e "\n$error_message\n"
  cleanup_vmid
}
# ==============================================================================
# PASSWORD GENERATION FUNCTION
# ==============================================================================
function generate_xkcd_password() {
  # Install xkcdpass if not available
  if ! command -v xkcdpass &>/dev/null; then
    msg_info "Installing xkcdpass for password generation"
    apt-get -qq update >/dev/null
    apt-get -qq install -y xkcdpass >/dev/null 2>&1 || pip3 install xkcdpass >/dev/null 2>&1
  fi

  # Select random separator from . - _
  local separators=("." "-" "_")
  local random_index=$((RANDOM % 3))
  local separator="${separators[$random_index]}"

  # Generate password with xkcdpass
  GENERATED_PASSWORD=$(xkcdpass -n 7 --min 4 --max 10 -d "$separator")
}

# ==============================================================================
# OS SELECTION FUNCTIONS
# ==============================================================================
function select_os() {
  if OS_CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SELECT OS" --radiolist \
    "Choose Operating System for Docker VM" 12 68 2 \
    "debian13" "Debian 13 (Trixie) - Latest" ON \
    "debian12" "Debian 12 (Bookworm) - Stable" OFF \
    3>&1 1>&2 2>&3); then
    case $OS_CHOICE in
    debian13)
      OS_TYPE="debian"
      OS_VERSION="13"
      OS_CODENAME="trixie"
      OS_DISPLAY="Debian 13 (Trixie)"
      ;;
    debian12)
      OS_TYPE="debian"
      OS_VERSION="12"
      OS_CODENAME="bookworm"
      OS_DISPLAY="Debian 12 (Bookworm)"
      ;;
    esac
    echo -e "${OS}${BOLD}${DGN}Operating System: ${BGN}${OS_DISPLAY}${CL}"
  else
    exit-script
  fi
}

function select_cloud_init() {
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "CLOUD-INIT" \
    --yesno "Enable Cloud-Init for VM configuration?\n\nCloud-Init allows automatic configuration of:\n- User accounts and passwords\n- SSH keys\n- Network settings (DHCP/Static)\n- DNS configuration\n\nYou can also configure these settings later in Proxmox UI.\n\nNote: Debian without Cloud-Init will use nocloud image with console auto-login." 18 68); then
    USE_CLOUD_INIT="yes"
    echo -e "${CLOUD}${BOLD}${DGN}Cloud-Init: ${BGN}yes${CL}"
  else
    USE_CLOUD_INIT="no"
    echo -e "${CLOUD}${BOLD}${DGN}Cloud-Init: ${BGN}no${CL}"
  fi
}

function select_sudo_password() {
  # Only prompt for sudo password when Cloud-Init is not used
  if [ "$USE_CLOUD_INIT" = "no" ]; then
    # Generate a random password using xkcdpass
    generate_xkcd_password
    local suggested_password="$GENERATED_PASSWORD"

    while true; do
      SUDO_PASSWORD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a sudo password for the Docker user\n\nPress Enter to use the generated password, or modify it:" 10 68 "$suggested_password" --title "SUDO PASSWORD" 3>&1 1>&2 2>&3)
      if [ $? -ne 0 ]; then
        exit-script
      fi
      if [ -z "$SUDO_PASSWORD" ]; then
        whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Password cannot be empty. Please enter a password." 8 58
        continue
      fi
      echo -e "${DEFAULT}${BOLD}${DGN}Sudo Password: ${BGN}${SUDO_PASSWORD}${CL}"
      break
    done
  fi
}

function select_ssh_port() {
  # Generate random port between 10000 and 65535
  RANDOM_PORT=$((RANDOM % 55536 + 10000))

  if PORT_CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SSH PORT" --radiolist \
    "Choose SSH Port Configuration\n\nGenerated random port: ${RANDOM_PORT}" 14 68 3 \
    "random" "Use generated random port (${RANDOM_PORT}) (Recommended)" ON \
    "default" "Use default SSH port (22)" OFF \
    "custom" "Enter custom port" OFF \
    3>&1 1>&2 2>&3); then
    case $PORT_CHOICE in
    random)
      SSH_PORT="$RANDOM_PORT"
      ;;
    default)
      SSH_PORT="22"
      ;;
    custom)
      while true; do
        if CUSTOM_PORT=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Enter custom SSH port (1024-65535)" 8 58 "$RANDOM_PORT" --title "CUSTOM SSH PORT" 3>&1 1>&2 2>&3); then
          if [[ "$CUSTOM_PORT" =~ ^[0-9]+$ ]] && [ "$CUSTOM_PORT" -ge 1024 ] && [ "$CUSTOM_PORT" -le 65535 ]; then
            SSH_PORT="$CUSTOM_PORT"
            break
          fi
          whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Port must be a number between 1024 and 65535." 8 58
        else
          exit-script
        fi
      done
      ;;
    esac
    echo -e "${DEFAULT}${BOLD}${DGN}SSH Port: ${BGN}${SSH_PORT}${CL}"
  else
    exit-script
  fi
}

function select_max_auth_tries() {
  while true; do
    if MAX_AUTH_TRIES=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set SSH MaxAuthTries (limits failed authentication attempts per connection)\n\nDefault: 6 (recommended)\nIncrease if you use multiple SSH keys" 12 68 "6" --title "SSH MAX AUTH TRIES" 3>&1 1>&2 2>&3); then
      if [ -z "$MAX_AUTH_TRIES" ]; then
        MAX_AUTH_TRIES="6"
      fi
      if [[ "$MAX_AUTH_TRIES" =~ ^[0-9]+$ ]] && [ "$MAX_AUTH_TRIES" -ge 1 ] && [ "$MAX_AUTH_TRIES" -le 100 ]; then
        echo -e "${DEFAULT}${BOLD}${DGN}SSH Max Auth Tries: ${BGN}${MAX_AUTH_TRIES}${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Value must be a number between 1 and 100." 8 58
    else
      exit-script
    fi
  done
}

function select_timezone() {
  while true; do
    if TIMEZONE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Timezone (IANA format)\n\nExamples: Europe/Amsterdam, America/New_York, Asia/Tokyo\n\nLeave empty for UTC" 12 68 "" --title "TIMEZONE" 3>&1 1>&2 2>&3); then
      if [ -z "$TIMEZONE" ]; then
        TIMEZONE="UTC"
      fi
      # Validate timezone format (basic check for Region/City pattern or UTC)
      if [[ "$TIMEZONE" == "UTC" ]] || [[ "$TIMEZONE" =~ ^[A-Za-z]+/[A-Za-z_]+$ ]]; then
        echo -e "${DEFAULT}${BOLD}${DGN}Timezone: ${BGN}${TIMEZONE}${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Invalid timezone format. Please use IANA format (e.g., Europe/Amsterdam)." 8 58
    else
      exit-script
    fi
  done
}

function select_komodo() {
  CONFIGURE_KOMODO="no"
  KOMODO_ALLOWED_IPS=""
  KOMODO_PUBLIC_KEY=""

  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "KOMODO CONFIGURATION" \
    --yesno "Do you want to configure Komodo?\n\nThis will:\n- Create a Komodo user\n- Configure Komodo settings\n- Open port 8120 in UFW firewall\n- Install Komodo" 12 68); then
    CONFIGURE_KOMODO="yes"
    echo -e "${DEFAULT}${BOLD}${DGN}Configure Komodo: ${BGN}yes${CL}"

    while true; do
      if KOMODO_IPS_INPUT=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Enter allowed IPs for Komodo (comma-separated)\n\nFormat: Each IP/CIDR must be in quotes, separated by commas\nExample: \"1.2.3.0/24\",\"1.2.3.4\",\"10.0.0.0/8\"\n\nLeave empty to allow all IPs" 14 68 "" --title "KOMODO ALLOWED IPS" 3>&1 1>&2 2>&3); then
        if [ -z "$KOMODO_IPS_INPUT" ]; then
          KOMODO_ALLOWED_IPS=""
          echo -e "${DEFAULT}${BOLD}${DGN}Komodo Allowed IPs: ${BGN}All${CL}"
          break
        fi
        # Validate format: should match pattern like "x.x.x.x" or "x.x.x.x/xx" with commas
        if [[ "$KOMODO_IPS_INPUT" =~ ^(\"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?\")(,\"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+)?\")*$ ]]; then
          KOMODO_ALLOWED_IPS="${KOMODO_IPS_INPUT}"
          echo -e "${DEFAULT}${BOLD}${DGN}Komodo Allowed IPs: ${BGN}${KOMODO_IPS_INPUT}${CL}"
          break
        fi
        whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Invalid format. Please use the format:\n\"1.2.3.0/24\",\"1.2.3.4\"\n\nEach IP must be in quotes and separated by commas." 10 58
      else
        exit-script
      fi
    done

    # Ask for Komodo Core Public Key (required)
    while true; do
      if KOMODO_KEY_INPUT=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Enter Komodo Core Public Key\n\nThis is used for authentication with Komodo Core." 10 68 "" --title "KOMODO CORE PUBLIC KEY" 3>&1 1>&2 2>&3); then
        if [ -z "$KOMODO_KEY_INPUT" ]; then
          whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Komodo Core Public Key is required." 8 58
          continue
        fi
        KOMODO_PUBLIC_KEY="$KOMODO_KEY_INPUT"
        echo -e "${DEFAULT}${BOLD}${DGN}Komodo Core Public Key: ${BGN}Configured${CL}"
        break
      else
        exit-script
      fi
    done

function get_image_url() {
  local arch=$(dpkg --print-architecture)
  if [ "$USE_CLOUD_INIT" = "yes" ]; then
    echo "https://cloud.debian.org/images/cloud/${OS_CODENAME}/latest/debian-${OS_VERSION}-generic-${arch}.qcow2"
  else
    echo "https://cloud.debian.org/images/cloud/${OS_CODENAME}/latest/debian-${OS_VERSION}-nocloud-${arch}.qcow2"
  fi
}

function get_valid_nextid() {
  local try_id
  try_id=$(pvesh get /cluster/nextid)
  while true; do
    if [ -f "/etc/pve/qemu-server/${try_id}.conf" ] || [ -f "/etc/pve/lxc/${try_id}.conf" ]; then
      try_id=$((try_id + 1))
      continue
    fi
    if lvs --noheadings -o lv_name | grep -qE "(^|[-_])${try_id}($|[-_])"; then
      try_id=$((try_id + 1))
      continue
    fi
    break
  done
  echo "$try_id"
}
function cleanup_vmid() {
  if qm status $VMID &>/dev/null; then
    qm stop $VMID &>/dev/null
    qm destroy $VMID &>/dev/null
  fi
}
function cleanup() {
  popd >/dev/null
  post_update_to_api "done" "none"
  rm -rf $TEMP_DIR
}
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null
function msg_info() {
  local msg="$1"
  echo -ne "${TAB}${YW}${HOLD}${msg}${HOLD}"
}
function msg_ok() {
  local msg="$1"
  echo -e "${BFR}${CM}${GN}${msg}${CL}"
}
function msg_error() {
  local msg="$1"
  echo -e "${BFR}${CROSS}${RD}${msg}${CL}"
}
function check_root() {
  if [[ "$(id -u)" -ne 0 || $(ps -o comm= -p $PPID) == "sudo" ]]; then
    clear
    msg_error "Please run this script as root."
    echo -e "\nExiting..."
    sleep 2
    exit
  fi
}
function arch_check() {
  if [ "$(dpkg --print-architecture)" != "amd64" ]; then
    echo -e "\n ${INFO}${YWB}This script will not work with PiMox! \n"
    echo -e "\n ${YWB}Visit https://github.com/asylumexp/Proxmox for ARM64 support. \n"
    echo -e "Exiting..."
    sleep 2
    exit
  fi
}
function ssh_check() {
  if command -v pveversion >/dev/null 2>&1; then
    if [ -n "${SSH_CLIENT:+x}" ]; then
      if whiptail --backtitle "Proxmox VE Helper Scripts" --defaultno --title "SSH DETECTED" --yesno "It's suggested to use the Proxmox shell instead of SSH, since SSH can create issues while gathering variables. Would you like to proceed with using SSH?" 10 62; then
        echo "you've been warned"
      else
        clear
        exit
      fi
    fi
  fi
}
function exit-script() {
  clear
  echo -e "\n${CROSS}${RD}User exited script${CL}\n"
  exit
}
function default_settings() {
  select_os
  select_cloud_init

  # SSH Key selection for Cloud-Init VMs (ask immediately after cloud-init decision)
  if [ "$USE_CLOUD_INIT" = "yes" ]; then
    configure_cloudinit_ssh_keys || true
  fi

  select_sudo_password
  select_ssh_port
  select_max_auth_tries
  select_timezone
  select_komodo

  VMID=$(get_valid_nextid)
  FORMAT=""
  MACHINE=" -machine q35"
  DISK_CACHE=""
  DISK_SIZE="10G"
  HN="docker"
  CPU_TYPE=" -cpu host"
  CORE_COUNT="2"
  RAM_SIZE="4096"
  BRG="vmbr0"
  MAC="$GEN_MAC"
  VLAN=""
  MTU=""
  START_VM="yes"
  METHOD="default"

  echo -e "${CONTAINERID}${BOLD}${DGN}Virtual Machine ID: ${BGN}${VMID}${CL}"
  echo -e "${CONTAINERTYPE}${BOLD}${DGN}Machine Type: ${BGN}Q35 (Modern)${CL}"
  echo -e "${DISKSIZE}${BOLD}${DGN}Disk Size: ${BGN}${DISK_SIZE}${CL}"
  echo -e "${DISKSIZE}${BOLD}${DGN}Disk Cache: ${BGN}None${CL}"
  echo -e "${HOSTNAME}${BOLD}${DGN}Hostname: ${BGN}${HN}${CL}"
  echo -e "${OS}${BOLD}${DGN}CPU Model: ${BGN}Host${CL}"
  echo -e "${CPUCORE}${BOLD}${DGN}CPU Cores: ${BGN}${CORE_COUNT}${CL}"
  echo -e "${RAMSIZE}${BOLD}${DGN}RAM Size: ${BGN}${RAM_SIZE}${CL}"
  echo -e "${BRIDGE}${BOLD}${DGN}Bridge: ${BGN}${BRG}${CL}"
  echo -e "${MACADDRESS}${BOLD}${DGN}MAC Address: ${BGN}${MAC}${CL}"
  echo -e "${VLANTAG}${BOLD}${DGN}VLAN: ${BGN}Default${CL}"
  echo -e "${DEFAULT}${BOLD}${DGN}Interface MTU Size: ${BGN}Default${CL}"
  echo -e "${GATEWAY}${BOLD}${DGN}Start VM when completed: ${BGN}yes${CL}"
  echo -e "${CREATING}${BOLD}${DGN}Creating a Docker VM using the above settings${CL}"
}
function advanced_settings() {
  select_os
  select_cloud_init

  # SSH Key selection for Cloud-Init VMs (ask immediately after cloud-init decision)
  if [ "$USE_CLOUD_INIT" = "yes" ]; then
    configure_cloudinit_ssh_keys || true
  fi

  select_sudo_password
  select_ssh_port
  select_max_auth_tries
  select_timezone
  select_komodo

  METHOD="advanced"
  [ -z "${VMID:-}" ] && VMID=$(get_valid_nextid)

  # VM ID
  while true; do
    if VMID=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Virtual Machine ID" 8 58 $VMID --title "VIRTUAL MACHINE ID" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$VMID" ]; then
        VMID=$(get_valid_nextid)
      fi
      if pct status "$VMID" &>/dev/null || qm status "$VMID" &>/dev/null; then
        echo -e "${CROSS}${RD} ID $VMID is already in use${CL}"
        sleep 2
        continue
      fi
      echo -e "${CONTAINERID}${BOLD}${DGN}Virtual Machine ID: ${BGN}$VMID${CL}"
      break
    else
      exit-script
    fi
  done

  # Machine Type
  if MACH=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "MACHINE TYPE" --radiolist --cancel-button Exit-Script "Choose Type" 10 58 2 \
    "q35" "Q35 (Modern, PCIe)" ON \
    "i440fx" "i440fx (Legacy, PCI)" OFF \
    3>&1 1>&2 2>&3); then
    if [ $MACH = q35 ]; then
      echo -e "${CONTAINERTYPE}${BOLD}${DGN}Machine Type: ${BGN}Q35 (Modern)${CL}"
      FORMAT=""
      MACHINE=" -machine q35"
    else
      echo -e "${CONTAINERTYPE}${BOLD}${DGN}Machine Type: ${BGN}i440fx (Legacy)${CL}"
      FORMAT=",efitype=4m"
      MACHINE=""
    fi
  else
    exit-script
  fi
  if DISK_SIZE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Disk Size in GiB (e.g., 10, 20)" 8 58 "$DISK_SIZE" --title "DISK SIZE" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    DISK_SIZE=$(echo "$DISK_SIZE" | tr -d ' ')
    if [[ "$DISK_SIZE" =~ ^[0-9]+$ ]]; then
      DISK_SIZE="${DISK_SIZE}G"
      echo -e "${DISKSIZE}${BOLD}${DGN}Disk Size: ${BGN}$DISK_SIZE${CL}"
    elif [[ "$DISK_SIZE" =~ ^[0-9]+G$ ]]; then
      echo -e "${DISKSIZE}${BOLD}${DGN}Disk Size: ${BGN}$DISK_SIZE${CL}"
    else
      echo -e "${DISKSIZE}${BOLD}${RD}Invalid Disk Size. Please use a number (e.g., 10 or 10G).${CL}"
      exit-script
    fi
  else
    exit-script
  fi
  if DISK_CACHE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "DISK CACHE" --radiolist "Choose" --cancel-button Exit-Script 10 58 2 \
    "0" "None (Default)" ON \
    "1" "Write Through" OFF \
    3>&1 1>&2 2>&3); then
    if [ $DISK_CACHE = "1" ]; then
      echo -e "${DISKSIZE}${BOLD}${DGN}Disk Cache: ${BGN}Write Through${CL}"
      DISK_CACHE="cache=writethrough,"
    else
      echo -e "${DISKSIZE}${BOLD}${DGN}Disk Cache: ${BGN}None${CL}"
      DISK_CACHE=""
    fi
  else
    exit-script
  fi
  # Hostname
  if VM_NAME=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Hostname" 8 58 docker --title "HOSTNAME" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $VM_NAME ]; then
      HN="docker"
    else
      HN=$(echo "${VM_NAME,,}" | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')
      if [ "$HN" != "${VM_NAME,,}" ]; then
        whiptail --backtitle "Proxmox VE Helper Scripts" --title "HOSTNAME ADJUSTED" --msgbox "Invalid characters detected. Hostname has been adjusted to:\n\n  $HN" 10 58
      fi
    fi
    echo -e "${HOSTNAME}${BOLD}${DGN}Hostname: ${BGN}$HN${CL}"
  else
    exit-script
  fi
  # CPU Model
  if CPU_TYPE1=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "CPU MODEL" --radiolist "Choose" --cancel-button Exit-Script 10 58 2 \
    "1" "Host (Recommended)" ON \
    "0" "KVM64" OFF \
    3>&1 1>&2 2>&3); then
    if [ $CPU_TYPE1 = "1" ]; then
      echo -e "${OS}${BOLD}${DGN}CPU Model: ${BGN}Host${CL}"
      CPU_TYPE=" -cpu host"
    else
      echo -e "${OS}${BOLD}${DGN}CPU Model: ${BGN}KVM64${CL}"
      CPU_TYPE=""
    fi
  else
    exit-script
  fi
  # CPU Cores
  while true; do
    if CORE_COUNT=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Allocate CPU Cores" 8 58 2 --title "CORE COUNT" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$CORE_COUNT" ]; then CORE_COUNT="2"; fi
      if [[ "$CORE_COUNT" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "${CPUCORE}${BOLD}${DGN}CPU Cores: ${BGN}$CORE_COUNT${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "CPU Cores must be a positive integer (e.g., 2)." 8 58
    else
      exit-script
    fi
  done

  # RAM Size
  while true; do
    if RAM_SIZE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Allocate RAM in MiB" 8 58 4096 --title "RAM" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$RAM_SIZE" ]; then RAM_SIZE="4096"; fi
      if [[ "$RAM_SIZE" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "${RAMSIZE}${BOLD}${DGN}RAM Size: ${BGN}$RAM_SIZE${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "RAM Size must be a positive integer in MiB (e.g., 4096)." 8 58
    else
      exit-script
    fi
  done
  # Bridge
  if BRG=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
    if [ -z $BRG ]; then
      BRG="vmbr0"
    fi
    echo -e "${BRIDGE}${BOLD}${DGN}Bridge: ${BGN}$BRG${CL}"
  else
    exit-script
  fi

  # MAC Address
  while true; do
    if MAC1=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a MAC Address" 8 58 $GEN_MAC --title "MAC ADDRESS" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$MAC1" ]; then
        MAC="$GEN_MAC"
        echo -e "${MACADDRESS}${BOLD}${DGN}MAC Address: ${BGN}$MAC${CL}"
        break
      fi
      if [[ "$MAC1" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        MAC="$MAC1"
        echo -e "${MACADDRESS}${BOLD}${DGN}MAC Address: ${BGN}$MAC${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "Invalid MAC address format. Use XX:XX:XX:XX:XX:XX (e.g., AA:BB:CC:DD:EE:FF)." 8 58
    else
      exit-script
    fi
  done
  # VLAN
  while true; do
    if VLAN1=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a Vlan (leave blank for default)" 8 58 --title "VLAN" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$VLAN1" ]; then
        VLAN1="Default"
        VLAN=""
        echo -e "${VLANTAG}${BOLD}${DGN}VLAN: ${BGN}$VLAN1${CL}"
        break
      fi
      if [[ "$VLAN1" =~ ^[0-9]+$ ]] && [ "$VLAN1" -ge 1 ] && [ "$VLAN1" -le 4094 ]; then
        VLAN=",tag=$VLAN1"
        echo -e "${VLANTAG}${BOLD}${DGN}VLAN: ${BGN}$VLAN1${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "VLAN must be a number between 1 and 4094, or leave blank for default." 8 58
    else
      exit-script
    fi
  done

  # MTU
  while true; do
    if MTU1=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Interface MTU Size (leave blank for default)" 8 58 --title "MTU SIZE" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
      if [ -z "$MTU1" ]; then
        MTU1="Default"
        MTU=""
        echo -e "${DEFAULT}${BOLD}${DGN}Interface MTU Size: ${BGN}$MTU1${CL}"
        break
      fi
      if [[ "$MTU1" =~ ^[0-9]+$ ]] && [ "$MTU1" -ge 576 ] && [ "$MTU1" -le 65520 ]; then
        MTU=",mtu=$MTU1"
        echo -e "${DEFAULT}${BOLD}${DGN}Interface MTU Size: ${BGN}$MTU1${CL}"
        break
      fi
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "INVALID INPUT" --msgbox "MTU Size must be a number between 576 and 65520, or leave blank for default." 8 58
    else
      exit-script
    fi
  done

  # Start VM
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "START VIRTUAL MACHINE" --yesno "Start VM when completed?" 10 58); then
    echo -e "${GATEWAY}${BOLD}${DGN}Start VM when completed: ${BGN}yes${CL}"
    START_VM="yes"
  else
    echo -e "${GATEWAY}${BOLD}${DGN}Start VM when completed: ${BGN}no${CL}"
    START_VM="no"
  fi
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create a Docker VM?" --no-button Do-Over 10 58); then
    echo -e "${CREATING}${BOLD}${DGN}Creating a Docker VM using the above advanced settings${CL}"
  else
    header_info
    echo -e "${ADVANCED}${BOLD}${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
}
function start_script() {
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "SETTINGS" --yesno "Use Default Settings?" --no-button Advanced 10 58); then
    header_info
    echo -e "${DEFAULT}${BOLD}${BL}Using Default Settings${CL}"
    default_settings
  else
    header_info
    echo -e "${ADVANCED}${BOLD}${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
}
# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
check_root
arch_check
pve_check

if whiptail --backtitle "Proxmox VE Helper Scripts" --title "Docker VM" --yesno "This will create a New Docker VM. Proceed?" 10 58; then
  :
else
  header_info && echo -e "${CROSS}${RD}User exited script${CL}\n" && exit
fi

start_script
post_to_api_vm

# ==============================================================================
# STORAGE SELECTION
# ==============================================================================
msg_info "Validating Storage"
while read -r line; do
  TAG=$(echo $line | awk '{print $1}')
  TYPE=$(echo $line | awk '{printf "%-10s", $2}')
  FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
  ITEM="  Type: $TYPE Free: $FREE "
  OFFSET=2
  if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
  fi
  STORAGE_MENU+=("$TAG" "$ITEM" "OFF")
done < <(pvesm status -content images | awk 'NR>1')
VALID=$(pvesm status -content images | awk 'NR>1')
if [ -z "$VALID" ]; then
  msg_error "Unable to detect a valid storage location."
  exit
elif [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID >/dev/null; then kill $SPINNER_PID >/dev/null; fi
  printf "\e[?25h"
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Storage Pools" --radiolist \
      "Which storage pool would you like to use for ${HN}?\nTo make a selection, use the Spacebar.\n" \
      16 $(($MSG_MAX_LENGTH + 23)) 6 \
      "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3)
  done
fi
msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
msg_ok "Virtual Machine ID is ${CL}${BL}$VMID${CL}."

# ==============================================================================
# PREREQUISITES
# ==============================================================================
if ! command -v virt-customize &>/dev/null; then
  msg_info "Installing libguestfs-tools"
  apt-get -qq update >/dev/null
  apt-get -qq install libguestfs-tools lsb-release -y >/dev/null
  apt-get -qq install dhcpcd-base -y >/dev/null 2>&1 || true
  msg_ok "Installed libguestfs-tools"
fi

# ==============================================================================
# IMAGE DOWNLOAD
# ==============================================================================
msg_info "Retrieving the URL for the ${OS_DISPLAY} Qcow2 Disk Image"
URL=$(get_image_url)
CACHE_DIR="/var/lib/vz/template/cache"
CACHE_FILE="$CACHE_DIR/$(basename "$URL")"
mkdir -p "$CACHE_DIR"
msg_ok "${CL}${BL}${URL}${CL}"

if [[ ! -s "$CACHE_FILE" ]]; then
  curl -f#SL -o "$CACHE_FILE" "$URL"
  echo -en "\e[1A\e[0K"
  msg_ok "Downloaded ${CL}${BL}$(basename "$CACHE_FILE")${CL}"
else
  msg_ok "Using cached image ${CL}${BL}$(basename "$CACHE_FILE")${CL}"
fi

# ==============================================================================
# STORAGE TYPE DETECTION
# ==============================================================================
STORAGE_TYPE=$(pvesm status -storage "$STORAGE" | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
nfs | dir)
  DISK_EXT=".qcow2"
  DISK_REF="$VMID/"
  DISK_IMPORT="--format qcow2"
  THIN=""
  ;;
btrfs)
  DISK_EXT=".raw"
  DISK_REF="$VMID/"
  DISK_IMPORT="--format raw"
  FORMAT=",efitype=4m"
  THIN=""
  ;;
*)
  DISK_EXT=""
  DISK_REF=""
  DISK_IMPORT="--format raw"
  ;;
esac

# ==============================================================================
# IMAGE CUSTOMIZATION WITH DOCKER
# ==============================================================================
msg_info "Preparing ${OS_DISPLAY} image with Docker"

WORK_FILE=$(mktemp --suffix=.qcow2)
cp "$CACHE_FILE" "$WORK_FILE"

export LIBGUESTFS_BACKEND_SETTINGS=dns=8.8.8.8,1.1.1.1

DOCKER_PREINSTALLED="no"

# Install qemu-guest-agent and Docker during image customization
msg_info "Installing base packages in image"
if virt-customize -a "$WORK_FILE" --install qemu-guest-agent,curl,ca-certificates,openssh-server >/dev/null 2>&1; then
  msg_ok "Installed base packages"

  msg_info "Installing Docker (this may take 2-5 minutes)"
  if virt-customize -q -a "$WORK_FILE" --run-command "curl -fsSL https://get.docker.com | sh" >/dev/null 2>&1 &&
    virt-customize -q -a "$WORK_FILE" --run-command "systemctl enable docker" >/dev/null 2>&1; then
    msg_ok "Installed Docker"

    msg_info "Configuring Docker daemon"
    # Optimize Docker daemon configuration
    virt-customize -q -a "$WORK_FILE" --run-command "mkdir -p /etc/docker" >/dev/null 2>&1
    virt-customize -q -a "$WORK_FILE" --run-command 'cat > /etc/docker/daemon.json << EOF
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF' >/dev/null 2>&1
    DOCKER_PREINSTALLED="yes"
    msg_ok "Configured Docker daemon"
  else
    msg_ok "Docker will be installed on first boot"
  fi
else
  msg_ok "Packages will be installed on first boot"
fi

msg_info "Finalizing image (hostname, SSH config)"
# Set hostname and prepare for unique machine-id
virt-customize -q -a "$WORK_FILE" --hostname "${HN}" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "truncate -s 0 /etc/machine-id" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "rm -f /var/lib/dbus/machine-id" >/dev/null 2>&1 || true
# Set timezone
virt-customize -q -a "$WORK_FILE" --timezone "${TIMEZONE}" >/dev/null 2>&1 || true

# Configure SSH for Cloud-Init
if [ "$USE_CLOUD_INIT" = "yes" ]; then
  virt-customize -q -a "$WORK_FILE" --run-command "passwd -l root" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*Port .*/Port ${SSH_PORT}/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*MaxAuthTries .*/MaxAuthTries ${MAX_AUTH_TRIES}/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*UsePAM .*/UsePAM no/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "echo '\nChallengeResponseAuthentication no' > /etc/ssh/sshd_config" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*AllowTcpForwarding .*/AllowTcpForwarding No/' /etc/ssh/sshd_config" >/dev/null 2>&1 || true
else
  # Configure auto-login for nocloud images (no Cloud-Init)
  virt-customize -q -a "$WORK_FILE" --run-command "mkdir -p /etc/systemd/system/serial-getty@ttyS0.service.d" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command 'cat > /etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
EOF' >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "mkdir -p /etc/systemd/system/getty@tty1.service.d" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command 'cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
EOF' >/dev/null 2>&1 || true
fi
msg_ok "Finalized image"

# Create Docker user and lock root user (only when Cloud-Init is not used)
if [ "$USE_CLOUD_INIT" = "no" ]; then
  msg_info "Creating Docker user and locking root user"
  virt-customize -q -a "$WORK_FILE" --run-command "passwd -l root" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "adduser --gecos GECOS --disabled-password ${HN}" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "adduser ${HN} sudo" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --password ${HN}:password:${SUDO_PASSWORD} >/dev/null 2>&1 || true
  msg_ok "${HN} Docker user created and root user locked"
fi

# Create first-boot Docker install script (fallback if virt-customize failed)
if [ "$DOCKER_PREINSTALLED" = "no" ]; then
  if virt-customize -q -a "$WORK_FILE" --run-command 'cat > /root/install-docker.sh << "DOCKERSCRIPT"
#!/bin/bash
exec > /var/log/install-docker.log 2>&1
echo "[$(date)] Starting Docker installation"

for i in {1..30}; do
  ping -c 1 8.8.8.8 >/dev/null 2>&1 && break
  sleep 2
done

apt-get update
apt-get install -y qemu-guest-agent curl ca-certificates openssh-server
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /etc/docker
cat > /etc/docker/daemon.json << DAEMON
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
DAEMON
systemctl restart docker

touch /root/.docker-installed
echo "[$(date)] Docker installation completed"
DOCKERSCRIPT
chmod +x /root/install-docker.sh' >/dev/null 2>&1; then

    virt-customize -q -a "$WORK_FILE" --run-command 'cat > /etc/systemd/system/install-docker.service << "DOCKERSERVICE"
[Unit]
Description=Install Docker on First Boot
After=network-online.target
Wants=network-online.target
ConditionPathExists=!/root/.docker-installed

[Service]
Type=oneshot
ExecStart=/root/install-docker.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
DOCKERSERVICE
systemctl enable install-docker.service' >/dev/null 2>&1 || true
  else
    msg_error "virt-customize failed for this image. Docker must be installed manually after first boot:"
    msg_error "  curl -fsSL https://get.docker.com | sh"
  fi
fi

# Configure bkup user
virt-customize -q -a "$WORK_FILE" --run-command "groupadd -g 1001 bkup" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "adduser --gecos GECOS --disabled-password --uid 1001 --gid 1001 bkup" >/dev/null 2>&1 || true

# Setup Komodo (only if configured)
if [ "$CONFIGURE_KOMODO" = "yes" ]; then
  msg_info "Configuring Komodo user and settings"
  virt-customize -q -a "$WORK_FILE" --run-command "groupadd -g 1337 komodo" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "adduser --gecos GECOS --disabled-password --uid 1337 --gid 1337 komodo" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "usermod -a-G docker komodo" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --password komodo:password:* >/dev/null 2>&1 || true

  # Setup docker file structure
  virt-customize -q -a "$WORK_FILE" --mkdir "/opt/docker" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --chown "1337:1337:/opt/docker" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --chmod "700:/opt/docker" >/dev/null 2>&1 || true

  # Configure Komodo
  virt-customize -q -a "$WORK_FILE" --mkdir "/home/komodo/.config/komodo" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "curl -o /home/komodo/.config/komodo/periphery.config.toml https://raw.githubusercontent.com/moghtech/komodo/refs/heads/main/config/periphery.config.toml" >/dev/null 2>&1 || true

  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's|^#*\s*root_directory =.*|root_directory = \"/home/komodo/periphery\"|' /home/komodo/.config/komodo/periphery.config.toml" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's|^#*\s*allowed_ips =.*|allowed_ips = \[${KOMODO_ALLOWED_IPS}\]|' /home/komodo/.config/komodo/periphery.config.toml" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's|^#*\s*stack_dir =.*|stack_dir = \"/opt/docker\"|' /home/komodo/.config/komodo/periphery.config.toml" >/dev/null 2>&1 || true
  virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's|^#*\s*core_public_keys =.*|core_public_keys = \"$KOMODO_PUBLIC_KEY\"|' /home/komodo/.config/komodo/periphery.config.toml" >/dev/null 2>&1 || true
  msg_ok "Configured Komodo"
fi

# Configure firewall
virt-customize -q -a "$WORK_FILE" --install "fail2ban,ufw" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "ufw default deny incoming" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "ufw default allow outgoing" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "ufw allow ${SSH_PORT}/tcp" >/dev/null 2>&1 || true
if [ "$CONFIGURE_KOMODO" = "yes" ]; then
  virt-customize -q -a "$WORK_FILE" --run-command "ufw allow 8120/tcp" >/dev/null 2>&1 || true
fi
virt-customize -q -a "$WORK_FILE" --run-command "sed -i 's/^#*\s*IPV6=.*/IPV6=no/' /etc/default/ufw" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "ufw --force enable" >/dev/null 2>&1 || true

# Disable IPV6
virt-customize -q -a "$WORK_FILE" --run-command "echo '\n\n# Disabling the IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1' > /etc/sysctl.conf" >/dev/null 2>&1 || true
virt-customize -q -a "$WORK_FILE" --run-command "sysctl -p" >/dev/null 2>&1 || true

# Resize disk to target size
msg_info "Resizing disk image to ${DISK_SIZE}"
qemu-img resize "$WORK_FILE" "${DISK_SIZE}" >/dev/null 2>&1
msg_ok "Resized disk image"

# ==============================================================================
# VM CREATION
# ==============================================================================
msg_info "Creating Docker VM shell"

qm create $VMID -agent 1${MACHINE} -tablet 0 -localtime 1 -bios ovmf${CPU_TYPE} -cores $CORE_COUNT -memory $RAM_SIZE \
  -name $HN -tags community-script -net0 virtio,bridge=$BRG,macaddr=$MAC$VLAN$MTU -onboot 1 -ostype l26 -scsihw virtio-scsi-pci >/dev/null

msg_ok "Created VM shell"

# ==============================================================================
# DISK IMPORT
# ==============================================================================
msg_info "Importing disk into storage ($STORAGE)"

if qm disk import --help >/dev/null 2>&1; then
  IMPORT_CMD=(qm disk import)
else
  IMPORT_CMD=(qm importdisk)
fi

IMPORT_OUT="$("${IMPORT_CMD[@]}" "$VMID" "$WORK_FILE" "$STORAGE" ${DISK_IMPORT:-} 2>&1 || true)"
DISK_REF_IMPORTED="$(printf '%s\n' "$IMPORT_OUT" | sed -n "s/.*successfully imported disk '\([^']\+\)'.*/\1/p" | tr -d "\r\"'")"
[[ -z "$DISK_REF_IMPORTED" ]] && DISK_REF_IMPORTED="$(pvesm list "$STORAGE" | awk -v id="$VMID" '$5 ~ ("vm-"id"-disk-") {print $1":"$5}' | sort | tail -n1)"
[[ -z "$DISK_REF_IMPORTED" ]] && {
  msg_error "Unable to determine imported disk reference."
  echo "$IMPORT_OUT"
  exit 226
}

msg_ok "Imported disk (${CL}${BL}${DISK_REF_IMPORTED}${CL})"

# Clean up work file
rm -f "$WORK_FILE"

# ==============================================================================
# VM CONFIGURATION
# ==============================================================================
msg_info "Attaching EFI and root disk"

qm set "$VMID" \
  --efidisk0 "${STORAGE}:0,efitype=4m" \
  --scsi0 "${DISK_REF_IMPORTED},${DISK_CACHE}${THIN%,}" \
  --boot order=scsi0 \
  --serial0 socket >/dev/null

qm set $VMID --agent enabled=1 >/dev/null

msg_ok "Attached EFI and root disk"

# Set VM description
set_description

# Cloud-Init configuration
if [ "$USE_CLOUD_INIT" = "yes" ]; then
  msg_info "Configuring Cloud-Init"
  CLOUDINIT_DEFAULT_USER="${HN}" setup_cloud_init "$VMID" "$STORAGE" "$HN" "yes"
  # Override the cloud-init password with xkcdpass-generated password
  generate_xkcd_password
  CLOUDINIT_PASSWORD="$GENERATED_PASSWORD"
  qm set "$VMID" --cipassword "$CLOUDINIT_PASSWORD" >/dev/null
  msg_ok "Cloud-Init configured"
fi

# Start VM
if [ "$START_VM" == "yes" ]; then
  msg_info "Starting Docker VM"
  qm start $VMID >/dev/null 2>&1
  msg_ok "Started Docker VM"
fi

# ==============================================================================
# FINAL OUTPUT
# ==============================================================================
VM_IP=""
if [ "$START_VM" == "yes" ]; then
  set +e
  for i in {1..10}; do
    VM_IP=$(qm guest cmd "$VMID" network-get-interfaces 2>/dev/null |
      jq -r '.[] | select(.name != "lo") | ."ip-addresses"[]? | select(."ip-address-type" == "ipv4") | ."ip-address"' 2>/dev/null |
      grep -v "^127\." | head -1) || true
    [ -n "$VM_IP" ] && break
    sleep 3
  done
  set -e
fi

echo -e "\n${INFO}${BOLD}${GN}Docker VM Configuration Summary:${CL}"
echo -e "${TAB}${DGN}VM ID: ${BGN}${VMID}${CL}"
echo -e "${TAB}${DGN}Hostname: ${BGN}${HN}${CL}"
echo -e "${TAB}${DGN}OS: ${BGN}${OS_DISPLAY}${CL}"
[ -n "$VM_IP" ] && echo -e "${TAB}${DGN}IP Address: ${BGN}${VM_IP}${CL}"

if [ "$DOCKER_PREINSTALLED" = "yes" ]; then
  echo -e "${TAB}${DGN}Docker: ${BGN}Pre-installed (via get.docker.com)${CL}"
else
  echo -e "${TAB}${DGN}Docker: ${BGN}Installing on first boot${CL}"
  echo -e "${TAB}${YW}Warning: Wait 2-3 minutes for installation to complete${CL}"
  echo -e "${TAB}${YW}Check progress: ${BL}cat /var/log/install-docker.log${CL}"
fi

if [ "$USE_CLOUD_INIT" = "yes" ]; then
  display_cloud_init_info "$VMID" "$HN" 2>/dev/null || true
fi

post_update_to_api "done" "none"
msg_ok "Completed successfully!\n"
