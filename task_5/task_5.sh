#!/bin/bash

# need to fix problem, authorization don't work on live cd !!!!!!!!

dist_name=$(curl -v --silent http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-install-amd64-minimal.txt 2>&1 |
grep -o "install-amd64-minimal-.*.iso")

# Download latest iso
download() {
  if ! [ -f "${dist_name}" ]
    then
      wget "http://distfiles.gentoo.org/releases/amd64/autobuilds/current-install-amd64-minimal/${dist_name}"
    else
      echo "Alredy downloaded"
    fi
}

# Extract iso
extract() {
  if ! [ -d iso/ ]; then
    mkdir iso/
  fi
  if ! [ -d iso-ori/ ]; then
    mkdir iso-ori/
  fi
  if ! [ -d sqfs-old/ ]; then
    mkdir sqfs-old/
  fi

  mount "${dist_name}" iso/ -o loop
  cp -a iso/* iso-ori/
  umount iso/
  rm -rf iso/
  cp -a iso-ori/ iso-new/ # copy original iso to dir for preparing new iso

  unsquashfs -f -d sqfs-old/ iso-ori/image.squashfs
  cp -a sqfs-old/ sqfs-new/
}

# Customize settings
modify() {

  # Added keys
  if ! [ -d sqfs-new/root/.ssh ]; then
    mkdir -p sqfs-new/root/.ssh
    echo "SSH dir created"
  fi
  cp -a ssh_keys/* sqfs-new/root/.ssh/
  chmod -R 644 ./sqfs-new/root/.ssh/*
  chown -R root:root sqfs-new/root/.ssh

  # Change config for root login
  echo "PermitRootLogin No" >> sqfs-new/etc/ssh/ssh_config

  # Start ssh server

}

# Merge difference
merge() {
  rm iso-new/image.squashfs
  mksquashfs sqfs-new/ iso-new/image.squashfs
  cd iso-new
  echo \#\!/bin/bash >> customize_iso.sh
  echo "mkisofs -R -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -iso-level 3 -o ../livecd.iso . " >> customize_iso.sh
  chmod +x customize_iso.sh
  ./customize_iso.sh
  cd ..
}


# Step 1
download
# Step 2
extract
# Step 3
modify
# Step 4
merge

Clean
rm -rf sqfs-old sqfs-new iso-ori iso-new initrd-old initrd-new


