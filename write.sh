#!/bin/bash
set -e

USB_DEV="/dev/sdc"
ISO_FILE="debian-11.8.0-unattended.iso"

echo ">>> WARNING: This will erase ${USB_DEV} completely."
read -p "Press ENTER to continue or CTRL+C to abort."

echo ">>> Wiping filesystem signatures..."
sudo wipefs -a ${USB_DEV}

echo ">>> Creating new msdos partition table..."
sudo parted ${USB_DEV} --script mklabel msdos

echo ">>> Creating primary FAT32 partition..."
sudo parted ${USB_DEV} --script mkpart primary fat32 1MiB 100%

echo ">>> Formatting partition as FAT32..."
sudo mkfs.vfat -F 32 ${USB_DEV}1

echo ">>> Writing ISO to USB (this will take a moment)..."
sudo dd if="${ISO_FILE}" of=${USB_DEV} bs=4M status=progress oflag=sync

echo ">>> Done. USB is ready."
