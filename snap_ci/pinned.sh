#!/bin/bash
# Pin commands to install vagrant, ansible, serverspec
# Pinning commands will ensure that they are ran in each snap-ci stage. This is
# usefull when you only want to re-run one stage.
set -e

# TODO: Move vagrant host to a preconifured VPS in same location as droplets to
# cut down on provisioning times. Use snap-ci just for provisioning tool to SSH
# to the Vagrant host and run the vagrant reload command.
# Cache and install Vagrant
[[ -f ${SNAP_CACHE_DIR}/$vagrant_rpm ]] || wget https://dl.bintray.com/mitchellh/vagrant/$vagrant_rpm -O ${SNAP_CACHE_DIR}/$vagrant_rpm
[[ -x /usr/bin/vagrant ]] || sudo -E rpm -ivh ${SNAP_CACHE_DIR}/$vagrant_rpm

# TODO: Check for vagrant plugins before installing them.
# An older version of digital_ocean plugin is used because of an issue with the
# current version that doesn't support using snapshots.
# https://github.com/smdahlen/vagrant-digitalocean/issues/187
vagrant plugin install vagrant-digitalocean --plugin-version '0.7.0'
vagrant plugin install vagrant-hostmanager

[[ -f ${SNAP_CACHE_DIR}/digital_ocean.box ]] || wget https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box -O ${SNAP_CACHE_DIR}/digital_ocean.box

# TODO: Check to see if the box was already added before doing again.
vagrant box add digital_ocean ${SNAP_CACHE_DIR}/digital_ocean.box --force

# Install Ansible dependencies
sudo yum install ansible -y

# TODO: Move serverspec tests to dedicated host to cut down provisioning times
# Install serverspec dependencies
sudo yum install ruby rubygems -y
gem install rspec serverspec bundler rake --no-ri --no-rdoc
