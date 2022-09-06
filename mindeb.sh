#!/bin/bash

#======================================================================#
#    __     ___  __      __   __   __   ___  __
#   |__) | |__  |__)    /  ` /  \ |  \ |__  |__)
#   |    | |___ |  \    \__, \__/ |__/ |___ |  \
#
#   my minimal debian post installation script
#======================================================================#

# Start with a minimal debian installation

# System utilities
sudo apt install -y man wget

# Microcode for AMD/Intel
# sudo apt install -y amd64-microcode
# sudo apt install -y intel-microcode 

# Window manager
sudo apt install -y i3
 
# Window manager rice
sudo apt install -y feh picom lxappearance fonts-font-awesome 

# Display manager
sudo apt install -y lightdm slick-greeter lightdm-settings 

# Audio
sudo apt install -y pulseaudio alsa-utils pavucontrol pasystray

# Notifications
sudo apt install -y dunst libnotify-bin 

# System-tray applets
sudo apt install -y flameshot diodon network-manager-gnome 

# Terminal
sudo apt install -y kitty

# File manager
sudo apt install -y thunar gvfs-backends gvfs-fuse 

# Text editor 
sudo apt install -y geany geany-common 

# Browser
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable*
rm google-chrome-stable*
