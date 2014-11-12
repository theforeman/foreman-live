#!/bin/bash
# vim: sw=2:ts=2:et
set -x
export repoowner=${1:-theforeman}
export branch=${2:-master}
NAME=foreman-live

# give the VM some time to finish booting and network configuration
ping -c1 8.8.8.8 2>&1 >/dev/null && echo OK || echo FAIL
yum -y install livecd-tools appliance-tools-minimizer \
  hardlink git wget pykickstart

# build plugin
pushd /root
SELINUXMODE=$(getenforce)
setenforce 1

[ -d $NAME ] || git clone https://github.com/$repoowner/$NAME.git -b $branch
pushd $NAME
git pull

./build-livecd flive-centos7.ks && sudo ./build-livecd-root
ls foreman-live/*iso -lah

popd
setenforce $SELINUXMODE
