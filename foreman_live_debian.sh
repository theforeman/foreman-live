# Guide to create debian based foreman-live.
# Configure envirnment
base="live"
arch="amd64"	#amd64 or i386
point="wheezy"	#wheezy,trusty...

# Install required tools
apt-get install xorriso live-build syslinux squashfs-tools

# Created envirnment and download/setup base image
mkdir $base && cd $base && base=$(pwd)
debootstrap --arch=$arch $point chroot

# Single command till comment end of echo
echo "# Change basic envirnment settings
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

# Install required packages
apt-get install -y linux-image-amd64 live-boot openssh-server

# Change hostname
echo "live.example.com" > /etc/hostname
echo "127.0.0.1       localhost" > /etc/hosts
echo "127.0.1.1       live.example.com	live" >> /etc/hosts
echo "::1             localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "fe00::0         ip6-localnet" >> /etc/hosts
echo "ff00::0         ip6-mcastprefix" >> /etc/hosts
echo "ff02::1         ip6-allnodes" >> /etc/hosts
echo "ff02::2         ip6-allrouters" >> /etc/hosts
sh /etc/init.d/hostname.sh

# Add foreman repo and install foreman-installer
echo "deb http://deb.theforeman.org/ wheezy 1.5" > /etc/apt/sources.list.d/foreman.list
echo "deb http://deb.theforeman.org/ plugins 1.5" >> /etc/apt/sources.list.d/foreman.list
wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
apt-get update && apt-get install -y foreman-installer

# Install foreman
foreman-installer --foreman-admin-password changeme

# Clear image & exit
echo "root:root" | chpasswd
apt-get clean
rm -rf /tmp/*
umount /proc /sys /dev/pts
exit" > $base/chroot/runme.sh
# End of echo

# Install foreman in chroot envirnment
chroot $base/chroot/ /bin/bash "runme.sh"

rm $base/chroot/runme.sh

# We are back in original base system
# Copy kernel and initrd image

mkdir -p $base/binary/live && mkdir -p $base/binary/isolinux
cp $base/chroot/boot/vmlinuz-3.2.0-4-amd64 $base/binary/live/vmlinuz
cp $base/chroot/boot/initrd.img-3.2.0-4-amd64 $base/binary/live/initrd
mksquashfs chroot $base/binary/live/filesystem.squashfs -comp xz -e boot
cp $base/chroot/usr/lib/syslinux/isolinux.bin $base/binary/isolinux/.
cp $base/chroot/usr/lib/syslinux/menu.c32 $base/binary/isolinux/.


# Create menu file
# Next couple of lines are single command!!!
echo "ui menu.c32
prompt 0
menu title Boot Menu
timeout 300

label foreman-live-amd64
	menu label ^Live (amd64)
	menu default
	linux /live/vmlinuz
 	append initrd=/live/initrd boot=live persistence quiet

label foreman-live-amd64-failsafe
	menu label ^Live (amd64 failsafe)
	linux /live/vmlinuz
	append initrd=/live/initrd boot=live persistence config memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal

endtext" > $base/binary/isolinux/isolinux.cfg

# Create hybridiso
cd $base/
xorriso -as mkisofs -r -J -joliet-long -l -cache-inodes -isohybrid-mbr $base/chroot/usr/lib/syslinux/isohdpfx.bin -partition_offset 16 \
-A "Foreman Live Debian"  -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o foreman-live-debian.iso binary

echo "Live ISO is ready with OS login root:root and foreman webgui login admin:changeme"
