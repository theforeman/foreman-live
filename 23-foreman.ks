%post

echo " * ensure /etc/os-release is present (needed for RHEL 7.0)"
yum -y install fedora-release centos-release redhat-release-server || \
  touch /etc/os-release

echo " * disabling legacy network services (needed for RHEL 7.0)"
systemctl disable network.service

echo " * enabling NetworkManager system services (needed for RHEL 7.0)"
systemctl enable NetworkManager.service
systemctl enable NetworkManager-dispatcher.service
systemctl enable NetworkManager-wait-online.service

echo " * enabling nm-prepare service"
systemctl enable nm-prepare.service

echo " * setting up journald and tty1"
rm -f /etc/systemd/system/getty.target.wants/getty@tty1.service
echo "SystemMaxUse=15M" >> /etc/systemd/journald.conf
echo "ForwardToSyslog=no" >> /etc/systemd/journald.conf
echo "ForwardToConsole=yes" >> /etc/systemd/journald.conf
echo "TTYPath=/dev/tty1" >> /etc/systemd/journald.conf

echo " * dropping some friendly aliases"
echo "alias vim=vi" >> /root/.bashrc

echo "192.168.223.2 livecd.example.com livecd" >> /etc/hosts

echo " * setting up hostname"
echo foreman.livecd.lan > /etc/hostname

echo " * setting up hosts"
cat > /etc/hosts << EOF
127.0.0.1   foreman.livecd.lan foreman
::1         foreman.livecd.lan foreman
EOF

echo " * adding desktop icons"
mkdir -p /home/liveuser/Desktop
cp /usr/share/applications/gnome-terminal.desktop /home/liveuser/Desktop/

echo " * disabling screen locking"
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t bool /apps/gnome-screensaver/lock_enabled "false"

%end
