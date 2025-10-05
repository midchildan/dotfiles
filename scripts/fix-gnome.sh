#!/usr/bin/env bash

# Script to reset some GNOME settings after switching from other desktop
# environments. Other desktop environments alter GNOME settings, probably to
# make GNOME applications play nice.
#
# https://discourse.gnome.org/t/kde-replaced-my-gnome-icons/26990
# https://discourse.nixos.org/t/gnome-broke-after-trying-plasma/16019

dconf reset -f /org/gnome/desktop/interface/
dconf reset -f /org/gnome/desktop/sound/
dconf reset -f /org/gnome/desktop/wm/preferences/
