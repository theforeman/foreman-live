Foreman-live
============

This repository contains scripts to build a livecd with foreman
pre-installed and configured on boot. Currently we have debian based
pure Foreman LiveCD and CentOS 6 based staypuft flavor CD that is
used to install OpenStack.

Using Foreman CentOS LiveCD
---------------------------

This LiveCD contains nightly build of Foreman with Foreman Discovery and
Foreman Staypuft plugin. It can be used for Foreman evaluation or testing out
the Staypuft OpenStack installer.

Required stuff:

* Bare metal or VM with at least 3 GB RAM
* Internet connectivity

After the image is started into graphical mode (X Window), it should auto
login and prepare the environment. New terminal should be opened. There are
few manual steps you have to take to get Foreman working. First get root
permissions and start the setup script

    sudo -i
    cd /home/liveuser/
    chmod ugo+x /home/liveuser/foreman_setup.sh
    ./foreman_setup.sh

This will start the staypuft installer. You will have to answer several
question regarding networking. When the installation finishes you should
see a Success message telling you on which domain the Foreman resides
and what's admin user password.

The network is currently statically configured (192.168.223.0). 
The installer can reconfigure the network according to the user input.

Once you have your Foreman running you can login as an admin and start
using Staypuft. For more information about the staypuft plugin, visit
[staypuft project page](https://github.com/theforeman/staypuft)

Build your LiveCD
-----------------

This document is based on http://fedoraproject.org/wiki/How_to_create_and_use_a_Live_CD

You must install tools using command (to be found in EPEL)

    yum install livecd-tools spin-kickstarts

You need kickstart and other scripts file from this github repository, 
so you should

    git clone https://github.com/theforeman/foreman-live
    cd foreman-live

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

When you boot the livecd you can run foreman_setup.sh script (under root) and
answer all questions to install fully functional foreman with staypuft
