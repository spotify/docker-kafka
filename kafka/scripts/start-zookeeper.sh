#!/bin/bash

# Default ZK configuration:
export ZOOKEEPER_tickTime=2000
export ZOOKEEPER_initLimit=10
export ZOOKEEPER_syncLimit=5
export ZOOKEEPER_dataDir="/var/lib/zookeeper"
export ZOOKEEPER_clientPort=2181

# Keep the helper header in the config :)
echo '# http://hadoop.apache.org/zookeeper/docs/current/zookeeperAdmin.html' > /etc/alternatives/zookeeper-conf/zoo.cfg
# Source configuration from variables names -
# Any environment variable starting with "ZOOKEEPER_"
# will be written to the ZK config file, ie:
# ZOOKEEPER_tickTime=100 results in 'tickTime=100' being written to ZK Config
for VAR in `printenv`; do
  NAME=${VAR%=*}
  VALUE=${VAR#*=}
  if [[ $NAME == "ZOOKEEPER_"* && $NAME != "ZOOKEEPER_SERVERS" && NAME != "ZOOKEEPER_MYID" ]]; then
    echo "$(echo $NAME | sed 's/ZOOKEEPER_//')=$VALUE" >> /etc/alternatives/zookeeper-conf/zoo.cfg
  fi
done

ZOOKEEPER_MYID=${ZOOKEEPER_MYID:-0}

echo ${ZOOKEEPER_MYID} > /etc/zookeeper/conf/myid
echo "# I am server #${ZOOKEEPER_MYID}" >> /etc/alternatives/zookeeper-conf/zoo.cfg

# Additionally, we'll provide a helper to allow users to easily define a set of ZK servers:
if [ -z ${ZOOKEEPER_SERVERS} ]; then
  SERVER_ID=1
  IFS=',' read -ra ADDR <<< "$ZOOKEEPER_SERVERS"
  for SERVER in "${ADDR[@]}"; do
    echo "server.${SERVER_ID}=${SERVER}" >> /etc/alternatives/zookeeper-conf/zoo.cfg
    ((SERVER_ID++))
  done
fi

cat /etc/alternatives/zookeeper-conf/zoo.cfg

/usr/share/zookeeper/bin/zkServer.sh start-foreground
