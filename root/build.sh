#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

echo "Checkout bootstrap..."
debootstrap \
   --arch=amd64 \
   --variant=minbase \
   bionic \
   $HOME/live-ubuntu-from-scratch/chroot \
   http://us.archive.ubuntu.com/ubuntu/

echo "Configure external mount points"
mount --bind /dev $HOME/live-ubuntu-from-scratch/chroot/dev
mount --bind /run $HOME/live-ubuntu-from-scratch/chroot/run

echo "===== Define chroot environment ====="

echo "Access chroot environment and create live cd"
cp ./setup_live_cd_packages.sh ./live-ubuntu-from-scratch/chroot/root/setup_live_cd_packages.sh
chroot $HOME/live-ubuntu-from-scratch/chroot /root/setup_live_cd_packages.sh

echo "Unbind mount points"
umount $HOME/live-ubuntu-from-scratch/chroot/dev
umount $HOME/live-ubuntu-from-scratch/chroot/run

$HOME/build_image.sh
$HOME/build_iso.sh
