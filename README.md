# 🖥️ Unattended Debian 11.8 USB Installer

## Overview

Everything in this guide is performed on a **Debian 11.8 (Bullseye)** machine that you already have up and running — this is your build machine.

---

## ⚙️ Preparation

You will need to install the following tools on your build machine:

- `wget`
- `xorriso`
- `isolinux`
- `syslinux-common`
- `genisoimage`
- `parted`
- `dosfstools`
- `rsync` *(comes pre-installed with Debian 11)*

Install them all with this single command:

```bash
sudo apt-get update && sudo apt-get install -y wget xorriso isolinux syslinux-common genisoimage parted dosfstools
```

---

## 📁 Set Up Your Workspace

Create a dedicated working folder in your home directory called `unattended`:

```bash
mkdir ~/unattended
```

Then change into that directory:

```bash
cd ~/unattended
```

This folder will hold all the files used in this project:

- `debian-11.8.0-amd64-netinst.iso`
- `preseed.cfg`
- `build_unattended_iso.sh`
- `write.sh`
- `debian-11.8.0-unattended.iso` *(once you build it)*

---

## 📥 Get the Debian ISO

From inside your `unattended` directory, download the official Debian 11.8 netinstall ISO:

```bash
wget https://cdimage.debian.org/cdimage/archive/11.8.0/amd64/iso-cd/debian-11.8.0-amd64-netinst.iso
```

---

## 📝 Create and Edit preseed.cfg

While still in your `unattended` directory, create the preseed file:

```bash
nano preseed.cfg
```

Copy the contents of [preseed.cfg](https://github.com/gphart1972/unattended-debian-11-8-USB-installer/blob/main/preseed.cfg) from this repository into the editor and make your changes — hostname, username, password, static IP, timezone, and so on.

Press **CTRL+O** to save and **CTRL+X** to exit nano.

---

## 🔨 Create the ISO Build Script

Create the build script:

```bash
nano build_unattended_iso.sh
```

Copy the contents of [build_unattended_iso.sh](https://github.com/gphart1972/unattended-debian-11-8-USB-installer/blob/main/build_unattended_iso.sh) from this repository into the editor and save it the same way.

---

## 🏗️ Build the Unattended ISO

Once you have edited `preseed.cfg` and created `build_unattended_iso.sh`, run the build script:

```bash
sudo bash build_unattended_iso.sh
```

This takes only a minute or two to complete. When it finishes, confirm the output ISO is there:

```bash
ls -lh
```

You should see `debian-11.8.0-unattended.iso` listed in your directory.

---

## 💾 Write the ISO to a USB Drive

Plug in the USB drive you want to use and run the following to identify it:

```bash
lsblk -fp
```

The output will look something like this:

```bash
user@hostname:~/unattended$ lsblk -fp
NAME        FSTYPE FSVER LABEL          UUID                                 FSAVAIL FSUSE% MOUNTPOINT
/dev/sda
/dev/sdb
├─/dev/sdb1 vfat   FAT32                1149-18DE                            505.2M     1% /boot/efi
├─/dev/sdb2 ext4   1.0                  fb5ef8aa-cd52-486d-af28-a1fe824034db 440.4G     1% /
└─/dev/sdb3 swap   1                    7a6f13e3-a157-4861-939a-d07eb0cf318f          [SWAP]
/dev/sdc
└─/dev/sdc1 ntfs         <volume_label> CAF63F34F63F205D
```

In this example the USB drive is at `/dev/sdc`. Make a note of your device name — you will need it in the next step.

> ⚠️ **Use the whole drive name** (e.g. `/dev/sdc`) and **not** a partition (e.g. `/dev/sdc1`).

### Create and run write.sh

Create the USB write script:

```bash
nano write.sh
```

Copy the contents of [write.sh](https://github.com/gphart1972/unattended-debian-11-8-USB-installer/blob/main/write.sh) from this repository into the editor. Before saving, update the `USB_DEV` line at the top to match your device name, then save and exit.

Once the script is ready, run it:

```bash
sudo bash write.sh
```

---

## 🚀 Install Debian on the Target Machine

Plug the USB into the machine you want to install Debian on and power it up. At the boot menu select **Install** — from that point everything is fully automated. The installer will work through the entire setup without stopping to ask for any input.

When the installation is complete the machine will **halt automatically**. Remove the USB drive and press the power button to boot into your new Debian installation.
