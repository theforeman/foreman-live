Foreman-live
============

This repository contains kickstart files to build a livecd with foreman 
pre-installed and configured on boot.

Howto is based on http://fedoraproject.org/wiki/How_to_create_and_use_a_Live_CD

Build your LiveCD
-----------------

You must install tools using command (to be found in EPEL)

    yum install livecd-tools spin-kickstarts

You need kickstart file from this github repository, currently

    git clone https://github.com/radez/foreman-live
    cd foreman-live

Then you must download discovery images, we currently use those 
from http://yum.theforeman.org/discovery/releases/0.3/

    wget http://yum.theforeman.org/discovery/releases/0.3/discovery-prod-0.3.0-1-initrd.img
    wget http://yum.theforeman.org/discovery/releases/0.3/discovery-prod-0.3.0-1-vmlinuz

Now you can the create a cd using this following command

    livecd-creator --verbose --config=foreman-live-centos.ks

This will create CentOS-Foreman-Live.iso. I recommend using cache so you don't
have to download all packages for every build. To setup cache you must pass
extra argument like this

    livecd-creator --verbose --config=foreman-live-centos.ks --cache=/var/cache/live

For the first time it will download a lot of data so it will take a lot of time.
If you want to modify existing iso (so you don't spend much time on reinstalling
whole base system every time you create new version) you can use --base-on parameter.
It will check installed packages on that image and add only missing. For some reason
it does not work for me, probably because of some package detection (lokkit) issue.
However you may try it

    livecd-creator --verbose --config=foreman-live-centos.ks --cache=/var/cache/live --base-on=livecd-foreman-live-centos-201403180812.iso

LiveCD has hardcoded network to run on 192.168.223.0/24 network, livecd.localdomain 
is binded on 192.168.223.2 and gateway is set to 192.168.223.1. 
You can create network in libvirt accordingly (NAT with disabled DHCP).

After your LiveCD boots up you must manually set networking using

    echo "nameserver 192.168.223.1\nnameserver 8.8.8.8" > /etc/resolv.conf

Then you can run foreman_setup.sh script (under root)
