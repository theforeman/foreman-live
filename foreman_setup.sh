#!/bin/bash

# add nameservers
echo "nameserver 192.168.223.2" | sudo tee /etc/resolv.conf
echo "nameserver 192.168.223.1" | sudo tee -a /etc/resolv.conf

#sync time for ssl cert generation
ntpdate 1.centos.pool.ntp.org

#working around  http://projects.theforeman.org/issues/4353
sudo rpm -e ruby193-rubygem-foreman_discovery

# live image deletes these, haven't investigated why, just add them and things work
sudo mkdir /var/log/foreman
sudo mkdir /var/run/foreman
sudo mkdir /var/log/foreman-proxy
sudo chown foreman:foreman /var/log/foreman
sudo chown foreman:foreman /var/run/foreman
sudo chown foreman-proxy:foreman-proxy /var/log/foreman-proxy

# do the install
sudo foreman-installer \
     --foreman-authentication=false \
     --enable-foreman-proxy \
     --foreman-proxy-tftp=true \
     --foreman-proxy-tftp-servername=192.168.223.2 \
     --foreman-proxy-dhcp=true \
     --foreman-proxy-dhcp-interface=eth0 \
     --foreman-proxy-dhcp-gateway=192.168.223.1 \
     --foreman-proxy-dhcp-range="192.168.223.3 192.168.223.255" \
     --foreman-proxy-dhcp-nameservers="192.168.223.2" \
     --foreman-proxy-dns=true \
     --foreman-proxy-dns-interface=eth0 \
     --foreman-proxy-dns-zone=example.com \
     --foreman-proxy-dns-reverse=223.168.192.in-addr.arpa \
     --foreman-proxy-dns-forwarders=192.168.223.1 \
     --foreman-proxy-foreman-base-url=https://livecd.example.com

# run puppet to seed data into foreman
sudo puppet agent -t

#adding discovery back in re: http://projects.theforeman.org/issues/4353
sudo yum localinstall -y http://yum.theforeman.org/releases/latest/el6/x86_64/foreman-release.rpm
sudo yum install -y ruby193-rubygem-foreman_discovery
sudo service httpd restart

# seed foreman with all necessary provisioning configuration
cd /home/liveuser
./setup_provisioning.rb
echo "Foreman seeded"
