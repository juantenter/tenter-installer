#!/usr/bin/env bash
# TENTER INSTALLER - colorful multi-distro Linux installer
set -uo pipefail

RESET='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
RED='\033[38;5;203m'; GREEN='\033[38;5;82m'; YELLOW='\033[38;5;220m'
BLUE='\033[38;5;75m'; MAGENTA='\033[38;5;177m'; CYAN='\033[38;5;87m'
WHITE='\033[97m'; GRAY='\033[38;5;245m'

APPS=("Brave" "Telegram" "Discord" "Proton VPN" "Firefox" "btop" "htop"
      "Alacritty" "LibreWolf" "LibreOffice" "Steam" "Fastfetch" "Cava")

if [[ ! -t 1 || -n "${NO_COLOR:-}" ]]; then
  RESET='' BOLD='' DIM='' RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE='' GRAY=''
fi

line(){ printf "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"; }
ok(){ printf "${GREEN}  ✔ %s${RESET}\n" "$*"; }
info(){ printf "${CYAN}  ➜ %s${RESET}\n" "$*"; }
warn(){ printf "${YELLOW}  ⚠ %s${RESET}\n" "$*"; }
fail(){ printf "${RED}  ✘ %s${RESET}\n" "$*"; }

banner(){
  clear 2>/dev/null || true
  printf "${MAGENTA}${BOLD}"
  cat <<'EOF'
 _____ _____ _   _ _____ _____ ____
|_   _| ____| \ | |_   _| ____|  _ \
  | | |  _| |  \| | | | |  _| | |_) |
  | | | |___| |\  | | | | |___|  _ <
  |_| |_____|_| \_| |_| |_____|_| \_\
EOF
  printf "${RESET}${CYAN}          MULTI-DISTRO INSTALLER${RESET}\n"
  printf "${DIM}       Automate your Linux setup. 🥀${RESET}\n"
  line
}

detect_pm(){
  if command -v pacman >/dev/null 2>&1; then PM=pacman
  elif command -v apt-get >/dev/null 2>&1; then PM=apt
  elif command -v dnf >/dev/null 2>&1; then PM=dnf
  elif command -v zypper >/dev/null 2>&1; then PM=zypper
  elif command -v apk >/dev/null 2>&1; then PM=apk
  elif command -v xbps-install >/dev/null 2>&1; then PM=xbps
  elif command -v eopkg >/dev/null 2>&1; then PM=eopkg
  else PM=unknown; fi
}

run_root(){
  if [[ $EUID -eq 0 ]]; then "$@"
  else sudo "$@"
  fi
}

install_pkgs(){
  local pkgs=("$@")
  ((${#pkgs[@]})) || return 1
  info "Installing: ${pkgs[*]}"
  case "$PM" in
    pacman) run_root pacman -S --needed --noconfirm "${pkgs[@]}" ;;
    apt) run_root apt-get update -y &&
         run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" ;;
    dnf) run_root dnf install -y "${pkgs[@]}" ;;
    zypper) run_root zypper --non-interactive install "${pkgs[@]}" ;;
    apk) run_root apk add "${pkgs[@]}" ;;
    xbps) run_root xbps-install -Sy "${pkgs[@]}" ;;
    eopkg) run_root eopkg install -y "${pkgs[@]}" ;;
    *) fail "Unsupported package manager"; return 1 ;;
  esac
}

install_flatpak(){
  local app_id="$1"
  if ! command -v flatpak >/dev/null 2>&1; then
    info "Installing Flatpak..."
    install_pkgs flatpak || return 1
  fi
  if ! flatpak remotes --columns=name 2>/dev/null | grep -qx flathub; then
    run_root flatpak remote-add --if-not-exists flathub \
      https://dl.flathub.org/repo/flathub.flatpakrepo || return 1
  fi
  flatpak install --system --assumeyes flathub "$app_id"
}

install_app(){
  local id="$1"
  printf "\n${BLUE}${BOLD}┌─ INSTALLING: %s${RESET}\n" "${APPS[$((id-1))]}"
  line
  case "$id" in
    1) # Brave
      if [[ $PM == pacman ]]; then
        if command -v yay >/dev/null 2>&1; then yay -S --needed --noconfirm brave-bin
        elif command -v paru >/dev/null 2>&1; then paru -S --needed --noconfirm brave-bin
        else install_flatpak com.brave.Browser; fi
      else
        if ! command -v curl >/dev/null 2>&1; then fail "curl is required"; return 1; fi
        # Official Brave install script. Review it before use if desired.
        curl -fsS https://dl.brave.com/install.sh | run_root sh
      fi
      ;;
    2) install_flatpak org.telegram.desktop ;;
    3) install_flatpak com.discordapp.Discord ;;
    4)
      warn "Proton VPN setup varies by distribution; opening official support page."
      if command -v xdg-open >/dev/null 2>&1; then
        xdg-open https://protonvpn.com/support/linux-ubuntu-vpn-setup/ >/dev/null 2>&1 &
      else
        info "https://protonvpn.com/support/"
      fi
      return 1
      ;;
    5) install_pkgs firefox ;;
    6) install_pkgs btop ;;
    7) install_pkgs htop ;;
    8) install_pkgs alacritty ;;
    9) install_flatpak io.gitlab.librewolf-community ;;
    10) if [[ $PM == pacman ]]; then install_pkgs libreoffice-fresh
        else install_pkgs libreoffice; fi ;;
    11)
      case "$PM" in
        pacman) install_pkgs steam ;;
        apt) warn "Steam may require enabling multiverse and i386 architecture."; install_pkgs steam ;;
        dnf) warn "Steam may require RPM Fusion."; install_pkgs steam ;;
        *) install_flatpak com.valvesoftware.Steam ;;
      esac ;;
    12) install_pkgs fastfetch ;;
    13) install_pkgs cava ;;
    *) fail "Invalid option"; return 1 ;;
  esac
}

menu_item(){
  printf " ${CYAN}%2s${RESET} ${WHITE}%-14s${RESET}" "$1" "$2"
}

detect_pm
banner
if [[ $PM == unknown ]]; then fail "No supported package manager found."; exit 1; fi

printf "${GREEN}${BOLD}  SYSTEM DETECTED${RESET}\n"
printf "  ${GRAY}Package manager:${RESET} ${YELLOW}%s${RESET}\n" "$PM"
line
printf "${MAGENTA}${BOLD}  BROWSERS & COMMUNICATION${RESET}\n"
menu_item 1 "Brave"; menu_item 2 "Telegram"; printf "\n"
menu_item 3 "Discord"; menu_item 4 "Proton VPN"; printf "\n"
menu_item 5 "Firefox"; menu_item 9 "LibreWolf"; printf "\n"
printf "\n${BLUE}${BOLD}  SYSTEM TOOLS${RESET}\n"
menu_item 6 "btop"; menu_item 7 "htop"; printf "\n"
menu_item 8 "Alacritty"; menu_item 12 "Fastfetch"; printf "\n"
menu_item 13 "Cava"; printf "\n"
printf "\n${YELLOW}${BOLD}  APPLICATIONS${RESET}\n"
menu_item 10 "LibreOffice"; menu_item 11 "Steam"; printf "\n"
line
printf " ${GREEN}${BOLD}14) INSTALL ALL PACKAGES${RESET}\n"
printf " ${RED} 0) Exit${RESET}\n"
line
read -r -p "$(printf "${MAGENTA}${BOLD}  Select option > ${RESET}")" choice

case "$choice" in
  0) info "Exiting."; exit 0 ;;
  14)
    failed=0
    for id in {1..13}; do
      if install_app "$id"; then ok "${APPS[$((id-1))]} completed"
      else fail "${APPS[$((id-1))]} failed or needs manual setup"; ((failed+=1)); fi
    done
    line
    if (( failed == 0 )); then ok "All installation commands completed!"
    else warn "$failed package(s) failed or need manual setup."; fi
    ;;
  *)
    if [[ $choice =~ ^([1-9]|1[0-3])$ ]]; then
      if install_app "$choice"; then ok "${APPS[$((choice-1))]} installation completed"
      else fail "Installation failed or needs manual setup."; exit 1; fi
    else fail "Invalid option."; exit 1; fi
    ;;
esac
printf "\n${MAGENTA}${BOLD}  TENTER INSTALLER${RESET}\n"
printf "${DIM}  Automating Linux, one command at a time. 🥀${RESET}\n"
