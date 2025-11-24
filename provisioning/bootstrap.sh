#!/usr/bin/env bash

# Global variables

HACK_REPOS=https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip

set -Eeuox pipefail
IFS=$'\n\t'

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

# msg "This is a ${RED}very important${NOFORMAT} message, but not a script output value!"
msg() {
  echo >&2 -e "${1-}"
}

setup_colors

# Pivilèges 
if [ "$(id -u)" -ne 0 ]; then
    msg "${RED}Ce script doit être lancé en root (sudo).${NOFORMAT}"
    exit 1
fi

# Update 
apt update && apt -y full-upgrade

# Outils classiques 
apt -y install \
    zsh tmux neovim git stow \
    python3 python3-pip python3-venv \
    curl wget unzip file \
    netcat-openbsd socat \
    build-essential strace ltrace \
    man-db

echo "[*] Créer un venv global pour pwntools…"
VENV_DIR=/opt/pwn-venv
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install pwntools capstone unicorn ropper ROPgadget

echo "[*] Ajout du venv au PATH pour tous les users…"
if ! grep -q "pwn-venv" /etc/profile; then
  echo 'export PATH=$PATH:/opt/pwn-venv/bin' >> /etc/profile
fi

echo "[*] Installer gdb + gef…"
if [ ! -d /opt/gef ]; then
  git clone https://github.com/hugsy/gef.git /opt/gef
  echo 'source /opt/gef/gef.py' >> /etc/gdb/gdbinit
fi

USER_NAME="bob"
chsh -s /usr/bin/zsh $USER_NAME

# Apparance
mkdir -p /usr/local/share/fonts/hack
wget -P /usr/local/share/fonts/hack \
"${HACK_REPOS}"

cd /usr/local/share/fonts/hack
unzip Hack.zip
fc-cache -fv


# Ok ! 
msg "${GREEN}Bootstrap terminé.${NOFORMAT}"

