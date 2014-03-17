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

You can the create a cd using this following command

    sudo livecd-creator --verbose --config=foreman-live-centos.ks --releasever=6.5

* releasever is CentOS version (usefull if you're working on fedora or other version than you want to build)
* config is path to kickstart file

This will create CentOS-Foreman-Live.iso. For the first time it will download a lot
of data so it will take a lot of time.

LiveCD has hardcoded network to run on 192.168.223.0/24 network, livecd.localdomain 
is binded on 192.168.223.2 and gateway is set to 192.168.223.1. 
You can create network in libvirt accordingly (NAT with disabled DHCP).

After your LiveCD boots up you must manually set networking using

    echo "nameserver 192.168.223.1\nnameserver 8.8.8.8" > /etc/resolv.conf

Then you can run foreman_setup.sh script (under root)
