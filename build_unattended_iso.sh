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
sed -i 's@append .*@append auto=true priority=critical vga=788 initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed/custom.cfg ---@' \
    "$WORKDIR/isolinux/txt.cfg"

echo ">>> Patching GRUB config..."
sed -i 's@linux.*@linux /install.amd/vmlinuz auto=true priority=critical preseed/file=/cdrom/preseed/custom.cfg ---@' \
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
