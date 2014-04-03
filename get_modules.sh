#!/bin/bash

ASTAPOR_VERSION="48781f62d3677f3f2aea996a4861109e7516c0b4"
OPENSTACK_MODULES_VERSION="d6c6a8c619c0b5fbcf8f9fbb3965f7fdf02947f8"

rm -rf astapor openstack-puppet-modules modules
mkdir modules

echo "Cloning repositories"
git clone https://github.com/redhat-openstack/astapor
git clone --recursive https://github.com/redhat-openstack/openstack-puppet-modules

pushd astapor
git reset --hard $ASTAPOR_VERSION
popd
pushd openstack-puppet-modules
git reset --hard $OPENSTACK_MODULES_VERSION
popd

mv astapor/puppet/modules/* modules
mv openstack-puppet-modules/* modules
rm -rf astapor openstack-puppet-modules 
