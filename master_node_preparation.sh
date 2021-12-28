#!/bin/sh
# ------------------------------------------------------------------
# Add user and network conf - sudo nano preparation.sh
# ------------------------------------------------------------------
ipAddress="10.1.2.91"
hostAddress="master"
userName="pi"
userPass="paaswd"

if [ $(id -u) -eq 0 ]; then
        useradd -m -p  $userPass  $userName
        usermod -aG sudo $userName
        usermod -aG admin $userName
else
        echo "Only root may add a user to the system."
        exit 2
fi

# sudo nano /etc/netplan/50-cloud-init.yaml
sed -i -e 's/^/#/' /etc/netplan/50-cloud-init.yaml
{
echo 'network:'
echo '    ethernets:'
echo '        eth0:'
echo '            dhcp4: false'
echo '            addresses: ['$ipAddress'/12]'
echo '            gateway4: 10.1.2.1'
echo '            nameservers:'
echo '                addresses: [10.1.2.254,8.8.8.8]'
echo '    version: 2'
echo '    wifis:'
echo '        wlan0:'
echo '            access-points:'
echo '                "SSID":'
echo '                    password: "passwd"'
echo '                "SSID":'
echo '                    password: "passwd"'
echo '            dhcp4: true'
echo '            optional: true'
} >> /etc/netplan/50-cloud-init.yaml

sed -i '/ubuntu/d' /etc/hostname
sed -i '/^$/d' /etc/hostname
echo $hostAddress >> /etc/hostname

# sudo nano /etc/hosts
sed -i -e 's/^/#/' /etc/hosts
{
echo 'fe00::0 ip6-localnet'
echo 'ff00::0 ip6-mcastprefix'
echo 'ff02::1 ip6-allnodes'
echo 'ff02::2 ip6-allrouters'
echo 'ff02::3 ip6-allhosts'
echo ''
echo '10.1.2.1               clusterhost'
echo '10.1.2.91              master'
echo '10.1.2.92              worker1'
echo '10.1.2.93              worker2'
echo '10.1.2.94              worker3'
} >> /etc/hosts


