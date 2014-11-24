%packages --excludedocs --nobase

# Debugging support
file

# SSH access
openssh-clients
openssh-server

# Starts all interfaces automatically for us
NetworkManager

# Used to update code at runtime
unzip

# Enable stripping
binutils

# Foreman packages
foreman
ruby193-rubygem-foreman_discovery
ruby193-rubygem-foreman_bootdisk
ruby193-rubygem-foreman_setup
foreman-installer

# Foreman dependencies
bind
bind-utils
dhcp
foreman-postgresql
foreman-proxy
foreman-selinux
httpd
mod_passenger
mod_ssl
postgresql-server
puppet
puppet-server
foreman-release-scl
foreman-cli
facter
ruby193-rubygem-passenger-native
rubygem-passenger-native
tftp-server
wget
xinetd

# Unnecessary desktop dependencies
-abattis-cantarell-fonts
-lohit-assamese-fonts
-lohit-bengali-fonts
-lohit-devanagari-fonts
-lohit-gujarati-fonts
-lohit-kannada-fonts
-lohit-malayalam-fonts
-lohit-marathi-fonts
-lohit-nepali-fonts
-lohit-oriya-fonts
-lohit-punjabi-fonts
-lohit-tamil-fonts
-lohit-telugu-fonts
-lklug-fonts
-madan-fonts
-sil-abyssinica-fonts
-sil-nuosu-fonts
-sil-padauk-fonts
-thai-scalable-fonts-common
-thai-scalable-waree-fonts
-vlgothic-fonts
-wqy-microhei-fonts

# selinux toolchain of policycoreutils, libsemanage, ustr
-policycoreutils
-checkpolicy
-selinux-policy*
-libselinux-python
-libselinux

%end
