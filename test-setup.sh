#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APT_BASE_LIST="$REPO_DIR/apt-base.txt"
APT_REPO_LIST="$REPO_DIR/apt-repo.txt"
FLATPAK_LIST="$REPO_DIR/flatpak.txt"

read_package_list() {
  local file="$1"
  grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$file"
}

echo "==> Updating apt package lists"
sudo apt update -y
sudo apt upgrade -y

echo "==> Installing base apt packages"
if [[ -f "$APT_BASE_LIST" ]]; then
  mapfile -t apt_base_packages < <(read_package_list "$APT_BASE_LIST")
  if ((${#apt_base_packages[@]})); then
    sudo apt install -y "${apt_base_packages[@]}"
  fi
else
  echo "Missing file: $APT_BASE_LIST" >&2
  exit 1
fi

echo "==> Enabling external repos"
sudo extrepo enable librewolf
sudo extrepo enable mullvad
sudo extrepo enable vscodium
sudo extrepo enable brave_release

echo "==> Enabling i386 architecture"
sudo dpkg --add-architecture i386

echo "==> Updating apt after enabling repos"
sudo apt update -y

echo "==> Installing repo-backed apt packages"
if [[ -f "$APT_REPO_LIST" ]]; then
  mapfile -t apt_repo_packages < <(read_package_list "$APT_REPO_LIST")
  if ((${#apt_repo_packages[@]})); then
    sudo apt install -y "${apt_repo_packages[@]}"
  fi
else
  echo "Missing file: $APT_REPO_LIST" >&2
  exit 1
fi

echo "==> Building and installing Mint themes"
mkdir -p "$HOME/themes-src"
cd "$HOME/themes-src"

if [[ ! -d mint-themes ]]; then
  git clone https://github.com/linuxmint/mint-themes.git
fi
cd mint-themes
make
sudo cp -r usr/share/themes/* /usr/share/themes/
cd "$HOME/themes-src"

echo "==> Installing Mint icons"
if [[ ! -d mint-y-icons ]]; then
  git clone https://github.com/linuxmint/mint-y-icons.git
fi
sudo cp -r mint-y-icons/usr/share/icons/* /usr/share/icons/

echo "==> Installing Mint cursors"
if [[ ! -d mint-y-cursors ]]; then
  git clone https://github.com/linuxmint/mint-y-cursors.git
fi
sudo cp -r mint-y-cursors/usr/share/icons/* /usr/share/icons/

cd "$HOME"
rm -rf "$HOME/themes-src"

echo "==> Setting up Flatpak"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "==> Installing Flatpak apps"
if [[ -f "$FLATPAK_LIST" ]]; then
  mapfile -t flatpak_packages < <(read_package_list "$FLATPAK_LIST")
  if ((${#flatpak_packages[@]})); then
    flatpak install -y flathub "${flatpak_packages[@]}"
  fi
else
  echo "Missing file: $FLATPAK_LIST" >&2
  exit 1
fi

echo "==> Applying Flatpak overrides"
flatpak override --user md.obsidian.Obsidian --filesystem="$HOME"
flatpak override --user com.bitwarden.desktop --filesystem="$HOME"

echo "==> Installing Catppuccin GNOME Terminal themes"
cd "$HOME"
if [[ ! -d gnome-terminal ]]; then
  git clone https://github.com/catppuccin/gnome-terminal.git
fi
cd gnome-terminal
python3 ./install.py
cd "$HOME"
rm -rf "$HOME/gnome-terminal"

echo "==> Installing Proton Mail desktop"
mkdir -p "$HOME/Downloads"
cd "$HOME/Downloads"
wget -O ProtonMail-desktop-beta.deb https://proton.me/download/mail/linux/ProtonMail-desktop-beta.deb
sudo apt install -y ./ProtonMail-desktop-beta.deb

echo "==> Installing Proton Mail Bridge"
wget -O protonmail-bridge_3.13.0-1_amd64.deb https://proton.me/download/bridge/protonmail-bridge_3.13.0-1_amd64.deb
sudo apt install -y ./protonmail-bridge_3.13.0-1_amd64.deb

echo "==> Done"
echo "Remember to:"
echo "  - verify your Cinnamon theme/icons/cursor in settings"
echo "  - select the Catppuccin terminal profile manually"
echo "  - add your custom PS1 to ~/.bashrc if you still want it"
