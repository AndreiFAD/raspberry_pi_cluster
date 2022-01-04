# raspberry_pi_cluster
raspberry_pi_cluster<br>
The main goal was to create a mini analysis lab for learning something new and practicing on one cluster from everywhere and I wrote a script for easier reinstall anytime.


Prerequisites<br>
5 Raspberry Pi 4 (4x4gb ram 1x8gb ram)<br>
USB power adapter<br>
gigabit switch<br>
5 USB-C cable<br>
5 UTP cable<br>
5 Micro sd card (I used 64 GB SanDisk ultra)<br>
Raspberry Pi cluster case with coolers

## Install OS:<br>
Raspberry Pi Imager (link) install the last version Debian Buster for host<br>
(Raspberry Pi OS Legacy with desktop)<br>

Download Ubuntu Server 18.04 LTS for the Raspberry Pi 4 (ARM 64-bit) (link) install for cluster nodes

## Setup the cluster host:<br>
Setup wifi and enable ssh before insert sd card to raspberry pi.

Create empty file on /boot partition "ssh"

Screenshot 2021-12-15 at 09.05.54.png
Create file on /boot partition "wpa_supplicant.conf"
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=NL
network={
  ssid="SSID name"
  psk="wifipass"
}
```

Screenshot 2021-12-15 at 09.05.30.png
After you insert the sd card, you have to set up a few things.

$ sudo raspi-config

Enable vnc <br>
GPU memory 256<br>
auto login with desktop<br>
update<br>
set display for vnc<br>
reboot<br>

$ sudo nano /etc/hostname<br>
clusterhost

sudo nano /etc/hosts<br>
```
10.1.2.1 clusterhost
10.1.2.91 master
10.1.2.92 worker1
10.1.2.93 worker2
10.1.2.94 worker3
```

Then we can set up a separate subnet:

Step 1: create a file – sudo nano bridge.sh<br>
copy this script to the file https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/clusterhost_network_setup.sh<br>
Step 2: Execute the script on your Pi like so.<br>
$ sudo bash bridge.sh<br>
Step 3: Reboot.<br>
$ sudo reboot

## Setup the cluster nodes:<br>
I made a script to set up the network for master and for workers. the different is only the variables in the top and master wlan0 is configured as well<br>
https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/master_node_preparation.sh

https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/workers_node_preparation.sh

Don’t forget to change these lines for your setup with both of the scripts:
```
ipAddress="10.1.2.91"
hostAddress="master"
userName="pi"
userPass="passwd for pi"
```
and for master node wlan0 configuration as well:<br>
```
echo '    wifis:'
echo '        wlan0:'
echo '            access-points:'
echo '                "<SSID>":'
echo '                    password: "<SSID passwd>"'
```
after you run it, you can give a new password to pi user:<br>
$ sudo passwd pi

To change your shell use the chsh command<br>
$ sudo su pi<br>
$ chsh -s /bin/bash pi


If you want to run 'sudo' command without entering a password:<br>
run: $ sudo visudo<br>
and add this line:<br>
```
pi ALL=(ALL) NOPASSWD: ALL
```

Generate public/private rsa key pair for user pi in all cluster nodes:<br>
$ ssh-keygen -t rsa

Copy the public keys to the authorized keys list:

$ cat .ssh/id_rsa.pub  >> .ssh/authorized_keys

And copy to all nodes:
```
cat ~/.ssh/id_rsa.pub | ssh clusterhost 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh master 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh worker1 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh worker2 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh worker3 'cat >> .ssh/authorized_keys'
```

You should do this process in each cluster node. In the end, all nodes will have all public keys in their lists. This is important — not having the key would prevent machine-to-machine communication after.

## install

This will be installed on every node:

Python3 libraries<br>
Jupyter notebook and lab<br>
Nodejs 12<br>
Hadoop-3.2.1<br>
Spark-2.4.5<br>
Zookeeper-3.6.3<br>
Kafka-2.13<br>
Apache-hive-3.1.2

This will be installed on the "master" node:

Postgresql 10<br>
jupyter kernels:<br>
Scala kernel<br>
Python3 kernel<br>
Sqlite3 kernel<br>
R kernel<br>
Julia kernel<br>
Bash kernel<br>

than you have to reboot all node


## first run on the master node:<br>
```
cd /opt/hive/bin
./schematool -dbType postgres -initSchema


hdfs namenode -format -force

start-dfs.sh
start-yarn.sh

cd /opt/spark
./sbin/start-all.sh

hdfs dfsadmin -safemode leave

hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -mkdir -p /tmp
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod -R 755 /tmp

/opt/hive/bin/hive –service metastore > /dev/null 2>&1 &
/opt/hive/bin/hive –service hiveserver2 > /dev/null 2>&1 &
```

http://master:8088/<br>
http://master:9870/<br>
http://master:8080/<br>
http://master:10002/<br>

go to folder – cd notebooks


$ jupyter notebook password
  
  
You can start jupyter with this command <br> 
$ /opt/spark/bin/pyspark –master spark://master:7077“

http://master:8888/lab



