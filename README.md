# Overview

Everything in this guide is performed on a Debian 11.8 (Bullseye) machine that you already have up and running — this is your build machine.

# Preparation

You will install a few tools to your working machine.

- wget
- xorriso
- isolinux
- syslinux-common
- genisoimage
- parted
- dosfstools
- rsync (comes installed with Debian 11)

You can install them all with this command:

```bash
sudo apt-get update && sudo apt-get install -y wget xorriso isolinux syslinux-common genisoimage parted dosfstools
```

## Setup your workspace

Create a dedicated working folder in your home directory called 'unattended'
```bash
mkdir ~/unattended
```
Then change to that directory.
```bash
cd ~/unattended
```

This folder will hold the files used in this project:

- debian-11.8.0-amd64-netinst.iso
- preseed.cfg
- build_unattended_iso.sh
- write.sh
- debian-11.8.0-unattended.iso (once you make it)

## Get the Debian ISO file

Next you will need the Debian ISO downloaded into your "unattended" working directory, so in terminal from that directory run

```bash
wget https://cdimage.debian.org/cdimage/archive/11.8.0/amd64/iso-cd/debian-11.8.0-amd64-netinst.iso
```
## Make and edit the preseed.cfg file

While you are still in the 'unattended' working directory:

```bash
nano preseed.cfg
```
Here is the link to the [preseed.cfg](https://github.com/gphart1972/unattended-debian-11-8-USB-installer/blob/main/preseed.cfg)

Copy the text of the preseed.cfg into nano and include your changes such as username, password, hostname, static IP info etc...

Then CTRL+O to save, and CTRL+X to exit nano

Next you will then need to create two other files in the same manner with nano that I have listed below.

## Create the ISO Build Script

```bash
nano build_unattended_iso.sh
```
Here is the link to the code for [build_unattended_iso.sh](https://github.com/gphart1972/unattended-debian-11-8-USB-installer/blob/main/build_unattended_iso.sh)

## Build the unattended ISO

Now if you have made your changes to the preseed.cfg file and you have made the 'build_unattended_iso.sh' script you are ready to run the script and make the unattended ISO

```bash
sudo bash build_unattended_iso.sh
```

This should not take long and then it finishes.

You can run:
```bash
ls -lh
```
In that directory and you should see your new ISO file.

## Write the new ISO to a USB Drive

Next plug in the USB that you want to make into the unattended installer and run:

```bash
lsblk -fp
```
Output will look something like this
```bash
user@hostname:~/unattended$ lsblk -fp
NAME        FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT
/dev/sda
/dev/sdb
├─/dev/sdb1 vfat   FAT32       1149-18DE                             505.2M     1% /boot/efi
├─/dev/sdb2 ext4   1.0         fb5ef8aa-cd52-486d-af28-a1fe824034db  440.4G     1% /
└─/dev/sdb3 swap   1           7a6f13e3-a157-4861-939a-d07eb0cf318f                [SWAP]
/dev/sdc
└─/dev/sdc1 ntfs         <volume_label> CAF63F34F63F205D
```
You can see above that the USB drive is at "/dev/sdc" 

## Create the write.sh script

Below is a script that deletes all data on the USB, makes a partition, formats the drive and copies the ISO to the USB and makes it bootable in the process.
Make sure you have the USB_DEV part at the top part of the script match your USB drive.
You run this script in the same folder as your new ISO file.

```bash
nano write.sh
```
Here is the code for [write.sh](https://github.com/gphart1972/unattended-debian-11-8-USB-installer/blob/main/write.sh)

Once you have the USB plugged in and you have the script corrected to the right device name, you can run it like this:

```bash
sudo bash write.sh
```
## Use the USB to Install OS

Now plug your USB into the machine you want to install Debian onto and start it up, 
once it boots in choose the second option "Install" and just wait, when it finishes, 
if you gave the preseed.cfg the right info, it will install everything,
without stopping to ask for input or errors and then at the end you will see it halt.
Then remove the USB device and hit the power button and reboot.
