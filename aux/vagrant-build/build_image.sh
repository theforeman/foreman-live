#!/bin/bash
# vim: sw=2:ts=2:et
set -x
PROJECT=foreman-live
export repoowner=${1:-theforeman}
export branch=${2:-master}

# give the VM some time to finish booting and network configuration
sleep 30

# build plugin
pushd /root
SELINUXMODE=$(getenforce)
setenforce 1

[ -d $PROJECT ] || git clone --depth 1 https://github.com/$repoowner/$PROJECT -b $branch
pushd $PROJECT
git pull
yum -y install epel-release
yum -y install git livecd-tools spin-kickstarts
git clone https://github.com/theforeman/foreman-live
pushd foreman-live
livecd-creator --verbose --config=foreman-live-centos.ks
ls -1
popd
ls -1

popd
setenforce $SELINUXMODE
