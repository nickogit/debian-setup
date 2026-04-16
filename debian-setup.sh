#!/usr/bin/env bash
set -euo pipefail

#prereqs:
#update /etc/apt/sources.list to include: 
#main contrib non-free non-free-firmware


#Setup for debian with cinnamon de

sudo apt update -y
sudo apt upgrade -y

#dep. installs + utils
sudo apt install -y \
git \
pysassc \
sassc \
make \
curl \
wget \
flatpak \
extrepo \
fastfetch \
openssh-client \
ca-certificates \
ufw \
gnupg \
nano \
apt-transport-https \
python3

#codecs
sudo apt install -y \
ffmpeg \
gstreamer1.0-libav \
gstreamer1.0-plugins-ugly \
gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-good

#ssh dir
mkdir -p ~/.ssh
chmod 700 ~/.ssh

#firewall defaults
sudo apt default deny incoming
sudo apt default allow outgoing
sudo ufw enable

#cinnamon themes
mkdir -p ~/themes-src && cd ~/themes-src
git clone https://github.com/linuxmint/mint-themes.git
cd mint-themes
make
sudo cp -r ~/themes-src/mint-themes/usr/share/themes/* /usr/share/themes/
cd ~/themes-src

#cinnamon icons
git clone https://github.com/linuxmint/mint-y-icons.git
sudo cp -r mint-y-icons/usr/share/icons/* /usr/share/icons/

#cinnamon cursors
git clone https://github.com/linuxmint/mint-y-cursors.git
sudo cp -r mint-y-cursors/usr/share/icons/* /usr/share/icons/

#cleanup
cd ~
rm -rf themes-src

#installing apt & extrepo apps
sudo extrepo enable librewolf 
sudo extrepo enable mullvad 
sudo extrepo enable vscodium 
sudo extrepo enable brave_release

sudo dpkg --add-architecture i386

sudo apt update

sudo apt install -y \
mullvad-vpn \
mullvad-browser \
librewolf \
codium \
brave-browser \
thunderbird \
steam

#installing flatpak apps

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
com.bitwarden.desktop \
com.discordapp.Discord \
com.github.iwalton3.jellyfin-media-player \
io.ente.auth \
md.obsidian.Obsidian \
org.signal.Signal \
org.torproject.torbrowser-launcher

#unhide line 60 to install heroic
#flatpak install com.heroicgameslauncher.hgl

#update flatpak perms for file uploads
flatpak override --user md.obsidian.Obsidian --filesystem="$HOME"
flatpak override --user com.bitwarden.desktop --filesystem="$HOME"

#bash and terminal themes

git clone https://github.com/catppuccin/gnome-terminal.git
cd gnome-terminal
./install.py

#cleanup
cd ~
rm -rf gnome-terminal

#select themes in terminal preferences the one i use is mocha

#add line 76 to end of ~/.bashrc
#PS1='\[\e[38;2;245;194;231m\]\u\[\e[0m\]\[\e[38;2;249;226;175m\]@\[\e[0m\]\[\e[38;2;137;180;250m\]\h \[\e[38;2;166;227;161m\]\w\[\e[0m\]\$ '

# Proton Mail desktop app

mkdir -p "$HOME/Downloads"
cd "$HOME/Downloads"
wget -O ProtonMail-desktop-beta.deb https://proton.me/download/mail/linux/ProtonMail-desktop-beta.deb
sudo apt install -y ./ProtonMail-desktop-beta.deb

# Proton Mail Bridge
wget -O protonmail-bridge_3.13.0-1_amd64.deb https://proton.me/download/bridge/protonmail-bridge_3.13.0-1_amd64.deb
sudo apt install -y ./protonmail-bridge_3.13.0-1_amd64.deb
