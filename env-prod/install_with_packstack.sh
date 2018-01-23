# generate configuration file for PackStack
packstack --gen-answer-file=ensimag-packstack.txt

# fill the configuration file with the required values
# assuming that the Controller node is 10.11.51.138 and Compute is 10.11.51.174
sed -i.bak \
	-e 's/^CONFIG_HEAT_INSTALL=n$/CONFIG_HEAT_INSTALL=y/' \
	-e 's/^CONFIG_COMPUTE_HOSTS=10.11.51.138$/CONFIG_COMPUTE_HOSTS=10.11.51.174/' \
	-e 's/^CONFIG_NETWORK_HOSTS=10.11.51.138$/CONFIG_NETWORK_HOSTS=10.11.51.138,10.11.51.174/' \
	-e 's/^CONFIG_NTP_SERVERS=.*$/CONFIG_NTP_SERVERS=10.3.252.26/'  \
	-e 's/^CONFIG_NEUTRON_ML2_TYPE_DRIVERS=.*$/CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan,flat,vlan/' \
	-e 's/^CONFIG_NEUTRON_ML2_FLAT_NETWORKS=.*$/CONFIG_NEUTRON_ML2_FLAT_NETWORKS=extnet/' \
	-e 's/^CONFIG_NEUTRON_ML2_VLAN_RANGES=.*$/CONFIG_NEUTRON_ML2_VLAN_RANGES=extnet:2232:2232/' \
	-e 's/^CONFIG_NEUTRON_OVS_BRIDGE_IFACES=.*$/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eno1/' \
	-e 's/^CONFIG_NEUTRON_OVS_BRIDGES_COMPUTE=.*$/CONFIG_NEUTRON_OVS_BRIDGES_COMPUTE=br-ex/' \
	-e 's/^CONFIG_PROVISION_DEMO=.*$/CONFIG_PROVISION_DEMO=n/' \
	ensimag-packstack.txt

# launch OpenStack installation by PackStack
packstack --answer-file=ensimag-packstack.txt
# in case of error due to database slowness, it may be useful to increase timeout : packstack --answer-file=ensimag-packstack.txt --timeout=600
# if case of DBError: (pymysql.err.InternalError) (1054, u"Unknown column 'cn.mapped' in 'field list'") follow these instructions :
# first verify that it is actually the problem : nova-manage cell_v2 discover_hosts
# if the previous command has failed, check the DB version used : nova-manage db version
# then update it : nova-manage db sync
# and check the new version number : nova-manage db version
# retry the failed operation : nova-manage cell_v2 discover_hosts
# which should succeed and then permit you to retry launching PackStack

# after the installation finishes successfully, check the Horizon's dashboard with credentials stored
source keystonerc_admin

# and to connect to Internet you will need to create a Neutron network for it
neutron net-create public --router:external --provider:network_type vlan --provider:physical_network extnet --provider:segmentation_id 2232
neutron subnet-create --name public-subnet --enable_dhcp=False --allocation-pool=start=10.11.54.10,end=10.11.54.29 --gateway=10.11.54.1 public 10.11.54.1/24
