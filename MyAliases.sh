#!/usr/bin/env bash

set -euo pipefail

BASHRC="$HOME/.bashrc"
ALIASES_FILE="$HOME/.aliases"
MARKER_START="# >>> AI cybersecurity aliases >>>"
MARKER_END="# <<< AI cybersecurity aliases <<<"

if [ -f "$BASHRC" ]; then
  cp "$BASHRC" "$BASHRC.backup.$(date +%Y%m%d_%H%M%S)"
else
  touch "$BASHRC"
fi

cat > "$ALIASES_FILE" <<'ALIASES_EOF'
# AI, cybersecurity, C, Python, Docker, Git, and Linux aliases
# Bash only

# -------------------------------------------------------------------
# Safer defaults
# -------------------------------------------------------------------

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'

# -------------------------------------------------------------------
# General shell shortcuts
# -------------------------------------------------------------------

alias ls='ls -lah --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo "$PATH" | tr ":" "\n"'

# -------------------------------------------------------------------
# Colorized output
# -------------------------------------------------------------------

alias grep='grep --color=auto'
alias eg='grep -E --color=auto'
alias fg='grep -F --color=auto'

# -------------------------------------------------------------------
# Directory and disk usage
# -------------------------------------------------------------------

alias md='mkdir -p'
alias rd='rmdir'
alias d='dirs -v'
alias df='df -h'
alias duh='du -h --max-depth=1'
alias mem='free -h'

# -------------------------------------------------------------------
# Bash config editing and reloading
# -------------------------------------------------------------------

alias ebrc='nano ~/.bashrc'
alias ealias='nano ~/.aliases'
alias sbrc='source ~/.bashrc'
alias salias='source ~/.aliases'

# -------------------------------------------------------------------
# Quick directory access
# -------------------------------------------------------------------

alias home='cd ~'
alias docs='cd ~/Documents'
alias dls='cd ~/Downloads'
alias desk='cd ~/Desktop'
alias projs='cd ~/Projects'

# -------------------------------------------------------------------
# APT package management
# Avoid generic aliases like install, remove, clean, search, show
# -------------------------------------------------------------------

alias aptu='sudo apt update'
alias aptup='sudo apt upgrade -y'
alias aptfull='sudo apt full-upgrade -y'
alias apti='sudo apt install'
alias aptrm='sudo apt remove'
alias aptpurge='sudo apt purge'
alias aptclean='sudo apt clean'
alias aptauto='sudo apt autoremove -y'
alias aptfix='sudo apt --fix-broken install'
alias aptsearch='apt search'
alias aptshow='apt show'
alias aptinstalled='apt list --installed'

# -------------------------------------------------------------------
# Git
# -------------------------------------------------------------------

alias gs='git status'
alias gst='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gps='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias glg='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias last='git log -1 --stat'

# -------------------------------------------------------------------
# Docker
# -------------------------------------------------------------------

alias dps='docker ps'
alias dpa='docker ps -a'
alias dstart='docker start'
alias dstop='docker stop'
alias drm='docker rm'
alias dimg='docker images'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dexec='docker exec -it'
alias dprune='docker system prune'

dbuildt() {
  if [ -z "${1:-}" ]; then
    echo "Usage: dbuildt <image_name:tag>"
    return 1
  fi

  docker build -t "$1" .
}

# -------------------------------------------------------------------
# Python and AI development
# -------------------------------------------------------------------


alias py='uv run python'                         # Run Python inside the project environment
alias pip='uv pip'                               # Use uv's pip-compatible interface
alias urun='uv run python'                       # Start IPython inside the project environment

alias venv='uv venv'                             # Create a local .venv using uv
alias uact='. .venv/bin/activate'                # Activate the local virtual environment
alias pipup='uv pip install --upgrade pip setuptools wheel'  # Upgrade core packaging tools inside .venv

alias pyclean='find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null'  # Remove Python cache folders
alias jsonpp='uv run python -m json.tool'        # Pretty-print and validate JSON from stdin or a file

alias pytestq='uv run pytest -q'                 # Run pytest in quiet mode
alias ruffc='uv run ruff check .'                # Run Ruff lint checks on the current project
alias rufff='uv run ruff format .'               # Format the project with Ruff
alias mypyc='uv run mypy .'                      # Run mypy type checks on the project

alias lab='uv run jupyter lab'                   # Start JupyterLab inside the project environment
alias nb='uv run jupyter notebook'               # Start classic Jupyter Notebook inside the project environment

alias uva='uv add'                               # Add a dependency to the project
alias uvr='uv remove'                            # Remove a dependency from the project
alias uvs='uv sync'                              # Sync .venv with pyproject.toml and uv.lock
alias uvl='uv lock'                              # Update or create uv.lock
alias uvt='uv tree'                              # Show the dependency tree
alias uvx='uvx'                                  # Run a Python tool without adding it to the project
alias uvlist='find "$HOME" -type d -name ".venv" -prune -exec du -sh {} \; 2>/dev/null'  # Find all .venv folders with their sizes
alias utree='uv pip tree'                        # see package dependency tree

# Create isolated uv environment in the current folder
uvenv() {
    uv venv && source .venv/bin/activate
}

# Create a new isolated project folder and enter it
unew() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: unew project_name [packages...]"
        return 1
    fi

    name="$1"
    shift

    mkdir -p "$name"
    cd "$name" || return 1

    uv init
    uv venv
    . .venv/bin/activate

    if [ "$#" -gt 0 ]; then
        uv add "$@"
    fi
}

# Install packages into the current isolated environment
upkg() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: upkg package1 package2 ..."
        return 1
    fi

    uv pip install "$@"
}



# -------------------------------------------------------------------
# GPU and CUDA checks
# -------------------------------------------------------------------

alias gpu='nvidia-smi'
alias gpumon='watch -n 1 nvidia-smi'
alias cudaver='nvcc --version'

torchgpu() {
  python3 - <<'PY'
try:
    import torch
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("Device:", torch.cuda.get_device_name(0))
        print("CUDA version:", torch.version.cuda)
except Exception as e:
    print("Torch check failed:", e)
PY
}

# -------------------------------------------------------------------
# C and C++ development
# -------------------------------------------------------------------

alias gccw='gcc -Wall -Wextra -Wpedantic -Wshadow -Wconversion -g'
alias gppw='g++ -Wall -Wextra -Wpedantic -Wshadow -Wconversion -g'
alias asan='gcc -Wall -Wextra -g -fsanitize=address -fno-omit-frame-pointer'
alias ubsan='gcc -Wall -Wextra -g -fsanitize=undefined'
alias makej='make -j$(nproc)'
alias cmakeconf='cmake -S . -B build'
alias cmakebuild='cmake --build build -j$(nproc)'
alias vg='valgrind --leak-check=full --track-origins=yes'
alias gdbq='gdb -q'

# -------------------------------------------------------------------
# Binary inspection and reverse engineering
# -------------------------------------------------------------------

alias sha='sha256sum'
alias md5='md5sum'
alias hex='xxd'
alias hdump='hexdump -C'
alias strs='strings -a'
alias elf='readelf -a'
alias syms='nm -C'
alias stracef='strace -f'
alias ltracef='ltrace -f'
alias filetype='file'

# -------------------------------------------------------------------
# Networking and cybersecurity
# -------------------------------------------------------------------

alias ports='ss -tulpen'                                          # What ports are open and listening on this machine?
alias connections='ss -antp'
alias listen='lsof -i -P -n'
alias checknet='ping -c 3 8.8.8.8'
alias myip='curl -4 ifconfig.me'
alias localip='hostname -I'
alias routes='ip route'
alias neigh='ip neigh'
alias dhr='sudo dhclient -r -v'
alias fw='sudo iptables -L -v -n'
alias sniff='sudo tcpdump -nn -i any'
alias sniff80='sudo tcpdump -nn -i any port 80'
alias sniff443='sudo tcpdump -nn -i any port 443'
alias nmapquick='nmap -sV -T4'                              
alias port='sudo lsof -i -P -n'                                   # Which processes currently have network sockets open?
alias portfind='lsof -i -P -n | grep'
alias speedtest='speedtest-cli --simple'

# -------------------------------------------------------------------
# Logs and system inspection
# -------------------------------------------------------------------

alias logs='journalctl -xe'
alias syslog='sudo journalctl -f'
alias dmesgerr='dmesg --level=err,warn'
alias services='systemctl --type=service --state=running'
alias failed='systemctl --failed'

# -------------------------------------------------------------------
# Other from LinuxWelt
# -------------------------------------------------------------------

alias x='xdg-open .'
alias path='echo -e ${PATH//:/\\n}'
alias http='python3 -m http.server 4444'


# -------------------------------------------------------------------
# Other 
# -------------------------------------------------------------------

alias k9='sudo pkill -9 -f'

# -------------------------------------------------------------------
# VPS hardening check aliases
# -------------------------------------------------------------------

vps_h_ssh() {
    echo "===== SSH hardening ====="
    sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|kbdinteractiveauthentication|pubkeyauthentication|allowusers|x11forwarding|allowtcpforwarding'
}
alias hssh='vps_h_ssh'

vps_h_firewall() {
    echo "===== Firewall ====="
    sudo ufw status numbered
}
alias hfw='vps_h_firewall'

vps_h_fail2ban() {
    echo "===== Fail2ban SSH ====="
    sudo fail2ban-client status sshd
}
alias hf2b='vps_h_fail2ban'

vps_h_wireguard() {
    echo "===== WireGuard ====="
    sudo wg
}
alias hwg='vps_h_wireguard'

vps_h_failed_services() {
    echo "===== Failed services ====="
    sudo systemctl --failed
}
alias hfailed='vps_h_failed_services'

vps_h_ports() {
    echo "===== Public listening ports ====="
    sudo ss -tulpn
}
alias hports='vps_h_ports'

vps_h_apache() {
    echo "===== Apache config ====="
    sudo apache2ctl configtest
}
alias hapache='vps_h_apache'

vps_h_https() {
    echo "===== HTTPS test ====="
    curl -I https://mamdouh.de/wp-login.php
}
alias hhttps='vps_h_https'

vps_h_wp_admins() {
    echo "===== WordPress admin users ====="
    sudo -u www-data wp user list --role=administrator --path=/var/www/mamdouh.de
}
alias hwpadmins='vps_h_wp_admins'

vps_h_uploads() {
    echo "===== Suspicious executable files in uploads ====="
    sudo find /var/www/mamdouh.de/wp-content/uploads -type f \( -name "*.php" -o -name "*.phtml" -o -name "*.phar" -o -name "*.cgi" -o -name "*.pl" -o -name "*.sh" \) -ls
}
alias huploads='vps_h_uploads'

vps_harden_list() {
    cat <<'LIST'
1. hssh
   Check SSH hardening
   sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|kbdinteractiveauthentication|pubkeyauthentication|allowusers|x11forwarding|allowtcpforwarding'

2. hfw
   Check UFW firewall rules
   sudo ufw status numbered

3. hf2b
   Check Fail2ban SSH jail
   sudo fail2ban-client status sshd

4. hwg
   Check WireGuard status
   sudo wg

5. hfailed
   Check failed systemd services
   sudo systemctl --failed

6. hports
   Check listening TCP and UDP ports
   sudo ss -tulpn

7. hapache
   Test Apache config
   sudo apache2ctl configtest

8. hhttps
   Test HTTPS response for WordPress login
   curl -I https://mamdouh.de/wp-login.php

9. hwpadmins
   List WordPress administrator users
   sudo -u www-data wp user list --role=administrator --path=/var/www/mamdouh.de

10. huploads
    Find suspicious executable files in WordPress uploads
    sudo find /var/www/mamdouh.de/wp-content/uploads -type f \( -name "*.php" -o -name "*.phtml" -o -name "*.phar" -o -name "*.cgi" -o -name "*.pl" -o -name "*.sh" \) -ls
LIST
}
alias hlist='vps_harden_list'

vps_harden_all() {
    hssh
    echo
    hfw
    echo
    hf2b
    echo
    hwg
    echo
    hfailed
    echo
    hports
    echo
    hapache
    echo
    hhttps
    echo
    hwpadmins
    echo
    huploads
}
alias hall='vps_harden_all'


# -------------------------------------------------------------------
# Find helpers
# -------------------------------------------------------------------

ffind() {
  if [ -z "${1:-}" ]; then
    echo "Usage: ffind <filename-pattern> [directory]"
    return 1
  fi

  find "${2:-.}" -type f -name "$1" 2>/dev/null
}

dfind() {
  if [ -z "${1:-}" ]; then
    echo "Usage: dfind <directory-pattern> [directory]"
    return 1
  fi

  find "${2:-.}" -type d -name "$1" 2>/dev/null
}

# -------------------------------------------------------------------
# Kill process by port
# -------------------------------------------------------------------

killport() {
  if [ -z "${1:-}" ]; then
    echo "Usage: killport <port>"
    return 1
  fi

  pids=$(sudo lsof -t -i:"$1" 2>/dev/null || true)

  if [ -z "$pids" ]; then
    echo "No process found on port $1"
    return 0
  fi

  echo "Killing process IDs on port $1:"
  echo "$pids"
  sudo kill $pids
}

# -------------------------------------------------------------------
# Project helpers
# -------------------------------------------------------------------

mkcd() {
  if [ -z "${1:-}" ]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi

  mkdir -p "$1"
  cd "$1" || return
}

extract() {
  if [ -z "${1:-}" ]; then
    echo "Usage: extract <archive>"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    return 1
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Unsupported archive type: $1" ;;
  esac
}

# -------------------------------------------------------------------
# Master Aliases
# -------------------------------------------------------------------

alias suspicious='printf "%s\n" "file FILE                 # type" "sha256sum FILE            # hash" "strings -a FILE           # text" "readelf -a FILE           # ELF info" "objdump -d FILE           # asm" "strace -f ./FILE          # syscalls" "tcpdump -nn               # packets"'

alias network='printf "%s\n" "===== NETWORK TROUBLESHOOTING COMMANDS =====" "1. ip -br a                         # IPs" "2. ip route                         # routes" "3. ip neigh                         # ARP" "4. ss -tulpen                       # listeners" "5. ss -tunap                        # sockets" "6. ss -s                            # stats" "7. lsof -i -P -n                    # open ports" "8. sudo ufw status verbose          # firewall" "9. sudo dhclient -r -v              # DHCP renew" "10. resolvectl status               # DNS" "11. sudo tcpdump -nn -i any         # sniff all" "12. sudo tcpdump -nn -i any port 443 # sniff HTTPS" "13. sudo nmap -sV 127.0.0.1         # scan local"'

alias servicecmds='printf "%s\n" "===== SERVICE TROUBLESHOOTING COMMANDS =====" "1. systemctl --failed                              # failed units" "2. systemctl status SERVICE --no-pager            # status" "3. sudo journalctl -u SERVICE -n 100 --no-pager   # logs" "4. sudo journalctl -u SERVICE -f                  # live logs" "5. sudo systemctl restart SERVICE                 # restart" "6. sudo systemctl reload SERVICE                  # reload" "7. systemctl is-enabled SERVICE                   # autostart" "8. systemctl list-units --type=service --state=running # running"'

alias processcmds='printf "%s\n" "===== PROCESS TROUBLESHOOTING COMMANDS =====" "1. ps aux --sort=-%cpu | head -n 20      # top CPU" "2. ps aux --sort=-%mem | head -n 20      # top RAM" "3. pgrep -af NAME                        # find proc" "4. pstree -p                             # proc tree" "5. sudo lsof -p PID                      # proc files" "6. xargs -0 -a /proc/PID/cmdline echo    # cmdline" "7. sudo kill -TERM PID                   # stop nice" "8. sudo kill -KILL PID                   # force kill"'

alias diskcmds='printf "%s\n" "===== DISK TROUBLESHOOTING COMMANDS =====" "1. df -hT                                  # disk space" "2. df -ih                                  # inode space" "3. lsblk -f                                # block devs" "4. findmnt                                 # mounts" "5. sudo du -xhd1 PATH | sort -h            # dir sizes" "6. sudo journalctl -p err -n 100 --no-pager # disk errors"'

alias syscmds='printf "%s\n" "===== SYSTEM TROUBLESHOOTING COMMANDS =====" "1. hostnamectl                    # host info" "2. uptime                         # load" "3. free -h                        # RAM" "4. vmstat 1 5                     # system stats" "5. sudo dmesg -T | tail -n 100    # kernel logs" "6. last reboot | head             # reboots"'

alias uvcmds='printf "%s\n" "===== UV SHORTCUTS =====" "ruffc     # lint" "rufff     # format" "uact      # activate venv" "uva PKG   # add pkg" "uvr PKG   # remove pkg" "uvs       # sync env" "uvl       # lock deps" "uvt       # dep tree" "uvx TOOL  # run tool" "uvlist    # find venvs" "utree     # pip tree" "uvenv     # make venv" "unew NAME # new project"'

alias knife='printf "%s\n" "===== LINUX TROUBLESHOOTING SWISS KNIFE =====" "1. network" "2. servicecmds" "3. processcmds" "4. diskcmds" "5. syscmds" "6. uvcmds"'


ALIASES_EOF

if ! grep -qF "$MARKER_START" "$BASHRC"; then
  cat >> "$BASHRC" <<RC_EOF

$MARKER_START
if [ -f "\$HOME/.aliases" ]; then
  . "\$HOME/.aliases"
fi
$MARKER_END
RC_EOF
fi

. "$ALIASES_FILE"

echo "Done."
echo "Aliases installed in: $ALIASES_FILE"
echo "Bash config updated: $BASHRC"
echo "Aliases are active in this terminal if you ran: source aliases.sh"
