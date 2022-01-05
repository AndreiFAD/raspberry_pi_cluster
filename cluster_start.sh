#!/bin/bash
# sudo nano start-cluster.sh

echo zookeeper worker1
ssh worker1 '/opt/zookeeper/bin/zkServer.sh start > /dev/null 2>&1 &'
echo zookeeper worker2
ssh worker2 '/opt/zookeeper/bin/zkServer.sh start > /dev/null 2>&1 &'
echo zookeeper worker3
ssh worker3 '/opt/zookeeper/bin/zkServer.sh start > /dev/null 2>&1 &'

echo kafka worker1
ssh worker1 '/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties > /dev/null 2>&1 &'
echo kafka worker2
ssh worker2 '/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties > /dev/null 2>&1 &'
echo kafka worker3
ssh worker3 '/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties > /dev/null 2>&1 &'

echo start hadoop cluster
start-dfs.sh
start-yarn.sh

echo start spark
cd /opt/spark
./sbin/start-all.sh

echo hive metastore
/opt/hive/bin/hive --service metastore > /dev/null 2>&1 &

echo hive hiveserver2
/opt/hive/bin/hive --service hiveserver2 > /dev/null 2>&1 &

echo "http://master:8088/"
echo "http://master:9870/"
echo "http://master:8080/"
echo "http://master:10002/"
echo "go to folder - cd notebooks"
echo "You can start with this command - /opt/spark/bin/pyspark --master spark://master:7077 --driver-memory 2500M --executor-memory 2500M"
echo "http://master:8888/lab"

