#!/bin/bash

# add nameservers
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

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
sudo staypuft-installer \
     --foreman-repo=nightly \
     --color-of-background bright
