#!/bin/sh
# Create a RAM disk with same perms as mountpoint
# Script based on https://gist.github.com/aazwar/7baeb7e0ca4ca259e416a735c87eb918 with some modifications
# Usage: sudo ./ramdisk.sh start

# MAINTENANCE
# Keep the size of DerivedData folder below the Ramdisk size.

USERNAME=$(logname)

DEV_CACHES_DIR="/Users/$USERNAME/Library/Developer/Xcode/DerivedData"
DEV_CACHES_SHADOW_DIR="/Users/$USERNAME/Library/Developer/Xcode/DerivedData.shadow"

RAMDisk() {
	mntpt="$1"
	rdsize=$(($2*1024*1024/512))
	
	# Create the RAM disk.
	dev=`hdik -drivekey system-image=yes -nomount ram://$rdsize`
	
	# Successfull creation...
	if [ $? -eq 0 ] ; then
		# Create HFS on the RAM volume.
		newfs_hfs $dev
		
		# Store permissions from old mount point.
		eval `/usr/bin/stat -s "$mntpt"`
		
		# Mount the RAM disk to the target mount point.
		mount -t hfs -o union -o nobrowse -o nodev -o noatime $dev "$mntpt"
		
		# Restore permissions like they were on old volume.
		chown $st_uid:$st_gid "$mntpt"
		chmod $st_mode "$mntpt"
		
		echo "Creating RamFS for $mntpt $rdsize $dev"
	fi
}

UmountDisk() {
	mntpt="$1"
	dev=`mount | grep "$mntpt" | grep hfs | cut -f 1 -d ' '`
	umount -f "$mntpt"
	hdiutil detach "$dev"
	echo "Umount RamFS for $mntpt $dev"
	echo ""
}

# Test for arguments.
if [ -z $1 ]; then
	echo "Usage: $0 [start|stop]"
	exit 1
fi

# Source common setup functions for startup scripts.
test -r /etc/rc.common || exit 1
. /etc/rc.common

StartService() {
	echo "Starting RamFS disks..."
	rm -r ~/Library/Developer/Xcode/DerivedData/*
	mkdir -p ~/Library/Developer/Xcode/DerivedData.shadow
	RAMDisk "$DEV_CACHES_DIR" 2048
	cp -rp "$DEV_CACHES_SHADOW_DIR/"* "$DEV_CACHES_DIR/"
}

StopService() {
	if [ -z "$(pgrep Xcode)" ]; then
		echo "Stopping RamFS disks..."
		/usr/bin/rsync -aqr --delete "$DEV_CACHES_DIR/" "$DEV_CACHES_SHADOW_DIR/"
		UmountDisk "$DEV_CACHES_DIR"
	else
		echo "Xcode is running, please close it first."
	fi	
}

RunService "$1"
