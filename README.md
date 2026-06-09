# Overview

Everything in this guide is performed on a Debian 11.8 (Bullseye) machine that you already have up and running — this is your build machine.

# Preparation

You will install a few tools to your working machine.

```code
wget
xorriso
isolinux
syslinux-common
genisoimage
parted
dosfstools
```

You can install them all with this command:

```code
sudo apt-get update && sudo apt-get install -y wget xorriso isolinux syslinux-common genisoimage parted dosfstools
```

## Setup your workspace

Create a dedicated working folder in your home directory called 'unattended'

This folder will hold the files used in this project:
```
-debian-11.8.0-amd64-netinst.iso

-preseed.cfg

-build_unattended_iso.sh

-write.sh

-debian-11.8.0-unattended.iso (once you make it)
```

## Make and edit the preseed.cfg file

Change directory to your working directory and execute:

```code
sudo nano preseed.cfg
```

Copy the text of the preseed.cfg show in this repo into there and include your changes such as username, password, hostname, static IP info etc...

Then CTRL+O to save, and CTRL+X to exit nano

Next you will then need to create two other files in the same manner with nano that I have listed below.

The first one is the script(build_unattended_iso.sh) used to build the ISO file, it will use the ISO file you download from Debian, include the preseed.cfg file as well as a few other changes and then make a working ISO file

```code
####################################
build_unattended_iso.sh
####################################
#!/bin/bash
set -e

ISO_IN="debian-11.8.0-amd64-netinst.iso"
ISO_OUT="debian-11.8.0-unattended.iso"
WORKDIR="iso_work"
MNTDIR="iso_mnt"

# Clean old dirs
sudo rm -rf "$WORKDIR" "$MNTDIR"
mkdir -p "$WORKDIR" "$MNTDIR"

echo ">>> Mounting original ISO..."
sudo mount -o loop "$ISO_IN" "$MNTDIR"

echo ">>> Copying ISO contents..."
rsync -a "$MNTDIR/" "$WORKDIR/"

echo ">>> Unmounting ISO..."
sudo umount "$MNTDIR"

echo ">>> Injecting preseed..."
mkdir -p "$WORKDIR/preseed"
cp preseed.cfg "$WORKDIR/preseed/custom.cfg"

echo ">>> Patching isolinux/txt.cfg..."
sed -i 's@append .*@append auto=true priority=critical vga=788 initrd=/install.amd/initrd.gz pr>
    "$WORKDIR/isolinux/txt.cfg"

echo ">>> Patching GRUB config..."
sed -i 's@linux.*@linux /install.amd/vmlinuz auto=true priority=critical preseed/file=/cdrom/pr>
    "$WORKDIR/boot/grub/grub.cfg"

echo ">>> Rebuilding ISO..."
xorriso -as mkisofs \
  -o "$ISO_OUT" \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -c isolinux/boot.cat \
  -b isolinux/isolinux.bin \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
     -no-emul-boot \
  "$WORKDIR"

echo ">>> Done!"
echo "Output ISO: $ISO_OUT"
```
## Get the Debian ISO file

Next you will need the Debian ISO downloaded into your "unattended" working directory, so in terminal from that directory run

```code
wget https://cdimage.debian.org/cdimage/archive/11.8.0/amd64/iso-cd/debian-11.8.0-amd64-netinst.iso
```

## Build the unattended ISO

Now if you have made your changes to the preseed.cfg file and you have made the 'build_unattended_iso.sh' script you are ready to run the script and make the unattended ISO

```code
sudo bash build_unattended_iso.sh
```

This should not take long and then it finishes.

You can run ls on that dir and you should see you new ISO file.

## Write the new ISO to a USB Drive

Next plug in the USB that you want to make into the unattended installer and run:

```code
lsblk -fp
```
this should show you your USB device and it will like have the name sdc or sdc1

anyhow, below is a script, make sure you have the USB_DEV part at the top setup with your device name, if you run this script in the same folder as your new ISO file, it will copy the ISO to the USB in a way that it will be bootable.

```code
#######################################
write.sh
#######################################
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
```
Once you have the USB plugged in and you have the script corrected to the right device name, you can run it like this:

```code
sudo bash write.sh
```

Now plug your USB into the machine you want to install Debian onto and start it up, 
once it boots in choose the second option "Install" and just wait, when it finishes, 
if you gave the preseed.cfg the right info, it will install everything,
without stopping to ask for input or errors and then at the end you will see it halt.
Then remove the USB device and hit the power button and reboot.
