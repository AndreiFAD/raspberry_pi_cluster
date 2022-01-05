# Analysis Lab on Raspberry Pi Cluster<br>
My goal was to build my own mini analysis lab to practice and learn something new. An environment what I can reach remotely with every device (with RealVNC) and of course a script with which I can be rebuilt quickly at any time.

I have learned a lot from the descriptions and solutions of others, you will find these links in the references as well!


## Prerequisites
5 Raspberry Pi 4 Model B (4x4gb ram 1x8gb ram) (link)<br>
USB power adapter, 6 port Charger 60W (link)<br>
Gigabit switch (D-Link Ethernet Switch, 5 Port) (link)<br>
5 USB-C cable (USB 3.1, 0.25 m) (link)<br>
5 Cat6 0.25m Gigabit Ethernet cable (link)<br>
5 Micro SD card (I used 5x SanDisk MicroSDXC Extreme 64GB) (link)<br>
Raspberry Pi cluster case with cooling fan and heatsink (link)

## Install OS:<br>
Raspberry Pi Imager (link) install the last version of Debian Buster for host
(Raspberry Pi OS Legacy with desktop)

Download Ubuntu Server 18.04 LTS for the Raspberry Pi 4 (ARM 64-bit) (link) image for cluster nodes


## Setup the cluster host:<br>
Setup wifi and enable ssh before insert sd card into raspberry pi.

Create empty file on /boot partition “ssh”
Create file on /boot partition “wpa_supplicant.conf”
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=NL
network={
  ssid="SSID name"
  psk="wifipass"
}
```
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
copy this script to the file or download it:<br> https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/clusterhost_network_setup.sh<br>
Step 2: Execute the script on your Pi like so.<br>
$ sudo bash bridge.sh<br>
Step 3: Reboot.<br>
$ sudo reboot



## Preparation of nodes (network, user, authorized keys):<br>
I made a script to set up the network for master and for workers. the different is only the variables in the top and master wlan0 is configured as well

https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/master_node_preparation.sh

https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/workers_node_preparation.sh

Don’t forget to change these lines for your setup with both of the scripts:<br>
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
After you run it, you can give a new password to pi user:<br>
$ sudo passwd pi

To change your shell use the chsh command<br>
$ sudo su pi<br>
$ chsh -s /bin/bash pi


If you want to run ‘sudo’ command without entering a password:<br>
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

## Install script for all node

This will be installed on every node:

Python3 libraries<br>
Jupyter notebook and lab<br>
Nodejs 12<br>
Hadoop-3.2.1<br>
Spark-2.4.5<br>
Zookeeper-3.6.3<br>
Kafka-2.13<br>
Apache-hive-3.1.2

This will be installed only on the "master" node:

Postgresql 10<br>
jupyter kernels:<br>
Scala kernel<br>
Python3 kernel<br>
Sqlite3 kernel<br>
R kernel<br>
Julia kernel<br>
Bash kernel<br>

You should run this script in each cluster node, the worker node 30-40 min/node, master 3-3,5h, but it depends on your network.

https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/install_script.sh<br>
It’s important, if you are using different host names, you have to change it here as well!

If you are done with all node you have to reboot them.


## First run on the master node:<br>
```
### Initiating the Hive metastore database schema:
cd /opt/hive/bin
./schematool -dbType postgres -initSchema

### it is necessary to format the data space and starting the cluster:
hdfs namenode -format -force

### start services Hadoop and Spark:
start-dfs.sh
start-yarn.sh

cd /opt/spark
./sbin/start-all.sh

### I also disabled the safe mode. To do this, after finishing the installation run:
hdfs dfsadmin -safemode leave

### Create Hive data warehouse on Hadoop filesystem:
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -mkdir -p /tmp
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod -R 755 /tmp

### You should start first the hive-metastore:
/opt/hive/bin/hive –service metastore > /dev/null 2>&1 &
### After initializing the hive-metastore, you should start the hiveserver2:
/opt/hive/bin/hive –service hiveserver2 > /dev/null 2>&1 &

```

Hadoop Datanode Information<br>
http://master:8088/<br>
Hadoop Cluster Information<br>
http://master:9870/<br>
Spark Information<br>
http://master:8080/<br>
Hive Information<br>
http://master:10002/<br>

go to folder –> $ cd notebooks<br>

Add password for jupyter, then you don’t have to use token:<br>
$ jupyter notebook password

You can start jupyter with this command:<br>
$ /opt/spark/bin/pyspark –master spark://master:7077“<br>

http://master:8888/lab<br>

Next time you can use this start script (with Zookeeper and Kafka service as well)<br>
https://raw.githubusercontent.com/AndreiFAD/raspberry_pi_cluster/main/cluster_start.sh



## References:


<p><a rel="noreferrer noopener" aria-label="https://nycdatascience.com/blog/student-works/raspberrypi3_bigdatacluster/1/  (új fülön nyitja meg)" href="https://nycdatascience.com/blog/student-works/raspberrypi3_bigdatacluster/1/" target="_blank">https://nycdatascience.com/blog/student-works/raspberrypi3_bigdatacluster/1/</a><br><a rel="noreferrer noopener" href="https://towardsdatascience.com/assembling-a-personal-data-science-big-data-laboratory-in-a-raspberry-pi-4-or-vms-cluster-ff37759cb2ec" target="_blank">https://towardsdatascience.com/assembling-a-personal-data-science-big-data-laboratory-in-a-raspberry-pi-4-or-vms-cluster-ff37759cb2ec</a><br><a rel="noreferrer noopener" href="https://github.com/kleinee/jns" target="_blank">https://github.com/kleinee/jns</a><br><a rel="noreferrer noopener" href="https://github.com/ptaranti/RaspberryPiCluster" target="_blank">https://github.com/ptaranti/RaspberryPiCluster</a><br><a rel="noreferrer noopener" href="https://docs.kyso.io/guides/sql-interface-within-jupyterlab" target="_blank">https://docs.kyso.io/guides/sql-interface-within-jupyterlab</a><br><a rel="noreferrer noopener" href="https://kontext.tech/column/hadoop/303/hiveserver2-cannot-connect-to-hive-metastore-resolutionsworkarounds" target="_blank">https://kontext.tech/column/hadoop/303/hiveserver2-cannot-connect-to-hive-metastore-resolutionsworkarounds</a><br><a rel="noreferrer noopener" href="https://github.com/sirCamp/tensorflow-kernels" target="_blank">https://github.com/sirCamp/tensorflow-kernels</a><br><a rel="noreferrer noopener" aria-label="https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart (új fülön nyitja meg)" href="https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart" target="_blank">https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart</a><br><a rel="noreferrer noopener" aria-label="https://www.shellcheck.net (új fülön nyitja meg)" href="https://www.shellcheck.net" target="_blank">https://www.shellcheck.net</a><br><a rel="noreferrer noopener" aria-label="https://pypi.org/project/spylon-kernel/ (új fülön nyitja meg)" href="https://pypi.org/project/spylon-kernel/" target="_blank">https://pypi.org/project/spylon-kernel/</a><br><a rel="noreferrer noopener" aria-label="https://www.linkedin.com/pulse/interfacing-r-from-python-3-jupyter-notebook-jared-stufft (új fülön nyitja meg)" href="https://www.linkedin.com/pulse/interfacing-r-from-python-3-jupyter-notebook-jared-stufft" target="_blank">https://www.linkedin.com/pulse/interfacing-r-from-python-3-jupyter-notebook-jared-stufft</a><br><a rel="noreferrer noopener" aria-label="https://people.duke.edu/~ccc14/sta-663/WrappingRLibraries.html (új fülön nyitja meg)" href="https://people.duke.edu/~ccc14/sta-663/WrappingRLibraries.html" target="_blank">https://people.duke.edu/~ccc14/sta-663/WrappingRLibraries.html</a><br><a rel="noreferrer noopener" aria-label="https://onlineguwahati.com/install-and-configuration-of-apache-hive-3-1-2-on-multi-node-hadoop-3-2-0-cluster-with-mysql-for-hive-metastore/ (új fülön nyitja meg)" href="https://onlineguwahati.com/install-and-configuration-of-apache-hive-3-1-2-on-multi-node-hadoop-3-2-0-cluster-with-mysql-for-hive-metastore/" target="_blank">https://onlineguwahati.com/install-and-configuration-of-apache-hive-3-1-2-on-multi-node-hadoop-3-2-0-cluster-with-mysql-for-hive-metastore/</a><br><a rel="noreferrer noopener" aria-label="https://linuxconfig.org/building-a-raspberry-pi-cluster-part-iv-monitoring (új fülön nyitja meg)" href="https://linuxconfig.org/building-a-raspberry-pi-cluster-part-iv-monitoring" target="_blank">https://linuxconfig.org/building-a-raspberry-pi-cluster-part-iv-monitoring</a><br><a rel="noreferrer noopener" aria-label="https://www.codeproject.com/Articles/1394735/A-4-Stack-rPI-Cluster-with-WiFi-Ethernet-Bridging (új fülön nyitja meg)" href="https://www.codeproject.com/Articles/1394735/A-4-Stack-rPI-Cluster-with-WiFi-Ethernet-Bridging" target="_blank">https://www.codeproject.com/Articles/1394735/A-4-Stack-rPI-Cluster-with-WiFi-Ethernet-Bridging</a><br><a href="https://www.ralfweinbrecher.de/post/multiple-wifi-networks-on-raspberrypi/" target="_blank" rel="noreferrer noopener" aria-label="https://www.ralfweinbrecher.de/post/multiple-wifi-networks-on-raspberrypi/ (új fülön nyitja meg)">https://www.ralfweinbrecher.de/post/multiple-wifi-networks-on-raspberrypi/</a></p>
