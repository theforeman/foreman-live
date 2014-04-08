#!/bin/bash

# add nameservers
echo "nameserver 192.168.223.2" | sudo tee /etc/resolv.conf
echo "nameserver 192.168.223.1" | sudo tee -a /etc/resolv.conf

#sync time for ssl cert generation
sudo ntpdate 1.centos.pool.ntp.org

# live image deletes these, haven't investigated why, just add them and things work
sudo mkdir /var/log/foreman
sudo mkdir /var/run/foreman
sudo mkdir /var/log/foreman-proxy
sudo chown foreman:foreman /var/log/foreman
sudo chown foreman:foreman /var/run/foreman
sudo chown foreman-proxy:foreman-proxy /var/log/foreman-proxy

# TODO change nighly to 1.5 stable when released or remove, since it's already installed on livecd
# do the install
sudo foreman-installer \
     --foreman-repo=nightly \
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
     --foreman-proxy-foreman-base-url=https://livecd.example.com \
     --no-enable-foreman-plugin-setup \
     --no-enable-foreman-plugin-bootdisk \


# run puppet to seed data into foreman
# TODO find some better way
sudo service puppet stop
sudo puppet agent -t
sudo service puppet start


# upload quickstack modules to /etc/puppet/environments/production/modules
cp -r /usr/local/src/modules/* /etc/puppet/environments/production/modules
# import quickstack modules
foreman-rake puppet:import:puppet_classes[batch]
# rerun seed because of staypuft
sudo foreman-rake db:seed

# seed foreman with all necessary provisioning configuration
cd /home/liveuser
./setup_provisioning.rb
echo "Foreman seeded"
