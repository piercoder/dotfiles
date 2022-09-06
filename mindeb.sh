#!/bin/bash

#======================================================================#
#    __     ___  __      __   __   __   ___  __
#   |__) | |__  |__)    /  ` /  \ |  \ |__  |__)
#   |    | |___ |  \    \__, \__/ |__/ |___ |  \
#
#   my minimal debian post installation script
#======================================================================#

# Start with a minimal debian installation

# Basic system stuff
sudo apt install man wget

# Window manager
sudo apt install i3
 
# Window manager rice
sudo apt install feh picom lxappearance fonts-font-awesome 

# Display manager
sudo apt install lightdm slick-greeter lightdm-settings 

# Audio
sudo apt install pulseaudio alsa-utils pavucontrol

# Notifications
sudo apt install dunst libnotify-bin 

# System-tray applets
sudo apt install flameshot diodon network-manager-gnome 

# Terminal
sudo apt install kitty

# File manager
sudo apt install thunar gvfs-backends gvfs-fuse 

# Text editor 
sudo apt install geany geany-common 

# Browser
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable*
rm google-chrome-stable*
