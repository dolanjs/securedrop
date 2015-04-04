require 'spec_helper'

['cron-apt'].each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

# Verify the file with the list of repos cron-apt will query for updates is
# present.
# TODO: verify there is nothing else in this file
describe file('/etc/apt/security.list') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode '644' }
  its(:content) { should match /deb http:\/\/security.ubuntu.com\/ubuntu trusty-security main/ }
  its(:content) { should match /deb-src http:\/\/security.ubuntu.com\/ubuntu trusty-security main/ }
  its(:content) { should match /deb http:\/\/security.ubuntu.com\/ubuntu trusty-security universe/ }
  its(:content) { should match /deb-src http:\/\/security.ubuntu.com\/ubuntu trusty-security universe/ }
  its(:content) { should match /deb \[arch=amd64\] https:\/\/apt.freedom.press trusty main/ }
  its(:content) { should match /deb http:\/\/deb.torproject.org\/torproject.org trusty main/ }
end

# Verify the cron job config is present
describe file('/etc/cron.d/cron-apt') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode '644' }
  its(:content) { should match /0 4 \* \* \* root    \/usr\/bin\/test -x \/usr\/sbin\/cron-apt && \/usr\/sbin\/cron-apt/ }
  its(:content) { should match /0 5 \* \* \* root    \/sbin\/reboot/ }
end

# Verify the signing keys for security updates are present by the full line of
# the fingerprint.
#
# Ubuntu Archive Automatic Signing Key
describe command("apt-key finger") do
  it { should return_stdout /^      Key fingerprint = 6302 39CC 130E 1A7F D81A  27B1 4097 6EAF 437D 05B5$/ }
end

# Ubuntu CD Image Automatic Signing Key
describe command("apt-key finger") do
  it { should return_stdout /^      Key fingerprint = C598 6B4F 1257 FFA8 6632  CBA7 4618 1433 FBB7 5451$/ }
end

# Ubuntu Archive Automatic Signing Key (2012)
describe command("apt-key finger") do
  it { should return_stdout /^      Key fingerprint = 790B C727 7767 219C 42C8  6F93 3B4F E6AC C0B2 1F32$/ }
end

# Ubuntu CD Image Automatic Signing Key (2012)
describe command("apt-key finger") do
  it { should return_stdout /^      Key fingerprint = 8439 38DF 228D 22F7 B374  2BC0 D94A A3F0 EFE2 1092$/ }
end

# Freedom of the Press Foundation Master Signing Key
describe command("apt-key finger") do
  it { should return_stdout /^      Key fingerprint = B89A 29DB 2128 160B 8E4B  1B4C BADD E0C7 FC9F 6818$/ }
end

# Tor signing key
describe command("apt-key finger") do
  it { should return_stdout /^      Key fingerprint = A3C4 F0F9 79CA A22C DBA8  F512 EE8C BC9E 886D DD89$/ }
end

# Verify there are no errors running apt-get update
describe command("apt-get update -o Dir::Etc::SourceList=/etc/apt/security.list -o Dir::Etc::SourceParts='/bin/null'" ) do
 it { should_not return_stderr }
end
