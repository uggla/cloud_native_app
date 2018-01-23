# change default password to a secure one
sudo passwd root

# make the system up-to-date
yum update

# PackStack installation setup (https://www.rdoproject.org/install/packstack/)

# install yum-config-manager which will be needed later
yum install yum-utils

# set the Locale
echo -e "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" > /etc/environment

# verify that the host has a fully qualified name
hostname --fqdn

# prepare network configuration
systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

# install packstack repo and binaries
yum install -y https://rdoproject.org/repos/rdo-release.rpm
yum install -y centos-release-openstack-pike
yum-config-manager --enable openstack-pike
yum install -y openstack-packstack

# finally reboot before to start installation
reboot

