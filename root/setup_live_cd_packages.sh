#!/bin/bash

echo "Configure mount points, home and locale"
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

echo "Set a custom hostname"
echo "puffin-live" > /etc/hostname

echo "Configure apt sources.list"
cat <<EOF > /etc/apt/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse

deb http://us.archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse
EOF

echo "Update indexes packages and install systemd"
apt-get update
apt-get install -y systemd-sysv

echo "Configure machine-id and divert"
#The /etc/machine-id file contains the unique machine ID of the local system that is set during installation or boot. 
#The machine ID is a single newline-terminated, hexadecimal, 32-character, lowercase ID. 
#When decoded from hexadecimal, this corresponds to a 16-byte/128-bit value. This ID may not be all zeros.
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

echo "Install packages needed for Live System"
DEBIAN_FRONTEND=noninteractive \
  apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    install -y \
    ubuntu-standard \
    casper \
    lupin-casper \
    discover \
    laptop-detect \
    os-prober \
    network-manager \
    resolvconf \
    net-tools \
    wireless-tools \
    wpagui \
    locales \
    linux-generic

echo "Graphical installer"
DEBIAN_FRONTEND=noninteractive \
  apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    install -y \
    ubiquity \
    ubiquity-casper \
    ubiquity-frontend-gtk \
    ubiquity-slideshow-ubuntu \
    ubiquity-ubuntu-artwork

echo "Install window manager"
apt-get install -y \
    plymouth-theme-ubuntu-logo \
    ubuntu-gnome-desktop \
    ubuntu-gnome-wallpapers

echo "Install useful applications"
apt-get install -y \
    clamav-daemon \
    terminator \
    apt-transport-https \
    curl \
    vim \
    less

echo "Remove unused applications"
apt-get purge -y \
    transmission-gtk \
    transmission-common \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    hitori \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    gnome-todo \
    thunderbird \
    thunderbird-gnome-support \
    ubuntu-docs \
    liberoffice-writer \
    rhythmbox \
    cheese \

echo "Remove amazon icons"
rm -rf /usr/share/applications/ubuntu-amazon-default.desktop
rm -rf /usr/share/unity-webapps/userscripts/unity-webapps-amazon/Amazon.user.js
rm -rf /usr/share/unity-webapps/userscripts/unity-webapps-amazon/manifest.json

echo "Remote liberoffice"
apt-get remove -y libreoffice* 

echo "Remove unused packages"
apt-get autoremove -y

echo "Generate locales"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "Config network"
resolvconf -u
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF

dpkg-reconfigure network-manager

echo "Cleanup the chroot environment"
truncate -s 0 /etc/machine-id

echo "Remove the diversion"
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

echo "Clean up"
apt-get clean
rm -rf /tmp/* ~/.bash_history
umount /proc
umount /sys
umount /dev/pts
export HISTSIZE=0

# exit chroot
exit
