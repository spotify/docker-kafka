#!/bin/bash

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic

function add_config_param {
    echo "$1: $2"
    if grep -q $1 $KAFKA_HOME/config/server.properties; then
        sed -r -i "s|($1)=(.*)|\1=$2|g" $KAFKA_HOME/config/server.properties
    else
        echo "$1=$2" >> $KAFKA_HOME/config/server.properties
    fi
}

# Set the external host and port
if [ ! -z "$ADVERTISED_HOST" ]; then
    echo "advertised host: $ADVERTISED_HOST"
    sed -r -i "s/#(advertised.host.name)=(.*)/\1=$ADVERTISED_HOST/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$ADVERTISED_PORT" ]; then
    add_config_param "port" $ADVERTISED_PORT
    echo "advertised port: $ADVERTISED_PORT"
    sed -r -i "s/#(advertised.port)=(.*)/\1=$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
fi

# Set the zookeeper chroot
if [ ! -z "$ZK_CHROOT" ]; then
    # wait for zookeeper to start up
    until /usr/share/zookeeper/bin/zkServer.sh status; do
      sleep 0.1
    done

    # create the chroot node
    echo "create /$ZK_CHROOT \"\"" | /usr/share/zookeeper/bin/zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=localhost:2181\/$ZK_CHROOT/g" $KAFKA_HOME/config/server.properties
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

## SSL
# add_config_param "security.inter.broker.protocol" "SSL"
add_config_param "ssl.enabled.protocols" "TLSv1.2,TLSv1.1,TLSv1"

add_config_param "listeners" "PLAINTEXT://:$ADVERTISED_PORT,SSL://:$ADVERTISED_SSL_PORT"
add_config_param "advertised.listeners" "PLAINTEXT://$ADVERTISED_HOST:$ADVERTISED_PORT,SSL://$ADVERTISED_HOST:$ADVERTISED_SSL_PORT"

# Configure SSL Location
if [ ! -z "$SSL_KEYSTORE_LOCATION" ]; then
    add_config_param "ssl.keystore.location" $SSL_KEYSTORE_LOCATION
    add_config_param "ssl.keystore.password" "changeit"
fi

# Configure SSL Truststore
if [ ! -z "$SSL_TRUSTSTORE_LOCATION" ]; then
    add_config_param "ssl.truststore.location" $SSL_TRUSTSTORE_LOCATION
    add_config_param "ssl.truststore.password" "changeit"
fi

# Configure auth
if [ ! -z "$SSL_CLIENT_AUTH" ]; then
    add_config_param "ssl.client.auth" $SSL_CLIENT_AUTH
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
