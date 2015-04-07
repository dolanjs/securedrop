#!/bin/bash
# The development snap-ci stage will:
# - Using DO snapshots of the a clean install of the most recent tagged version
# used in production, will up the development droplets.
# - Will re-provision the development environment based on the
# DEVELOPMENT_SKIP_TAGS environment variable.
#
# Requires the pinned commands to have already ran
# /bin/bash ./snap-ci/pinned.sh
# snap-wait 20 /bin/bash ./snap-ci/development-upgrade.sh

# Snap-CI environment variables required:
# vagrant_rpm vagrant_1.7.2_x86_64.rpm
# DO_SSH_KEYFILE_NAME Vagrant
# DO_IMAGE_NAME {HOSTNAME}-{TAGGED-VERSION}
# DO_REGION nyc3
# DO_SIZE 1gb
# DEVELOPMENT_SKIP_TAGS non-development
# DO_API_TOKEN ***
#
# Snap-CI Secure Files required:
# Owner Logical Name            File         Mode
# USER  snap_digital_ocean      /var/snap-ci/repo/id_rsa        0600
# USER  snap_digital_ocean.pub  /var/snap-ci/repo/id_rsa.pub    0600
#set -e

# The droplet should be running a fresh install of the previous tagged version
# of SecureDrop.
vagrant up development --no-provision
vagrant status development | grep 'running'

vagrant provision development

# Run serverspec tests
cd /var/snap-ci/repo/spec_tests/
# TODO: Need to fix versioning mismatch of what is installed on snap-ci compared
# to tests. Commented out running serverspec tests till then.
#rake spec

# Destroy the droplets since you will want to start builds with a fresh tagged
# release and to save money.
#vagrant destroy development -f
