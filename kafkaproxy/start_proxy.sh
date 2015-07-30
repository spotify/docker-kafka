#!/bin/sh

: ${KAFKA_HOME:?"Need to configure KAFKA_HOME"}
: ${CONSUMER_THREADS:?"Need to configure CONSUMER_THREADS"}
: ${TOPICS:?"Need to configure TOPICS whitelist"}
: ${ZK_CONNECT:?"Need to configure ZK_CONNECT string"}
: ${GROUP_ID:?"Need to configure GROUP_ID string"}

sed -i "s/mirror.consumer.numthreads=.*/mirror.consumer.numthreads=$CONSUMER_THREADS/" /consumer.properties
sed -i "s/zk.connect=.*/$ZK_CONNECT/" /consumer.properties
sed -i "s/groupid=.*/$GROUP_ID/" /consumer.properties

cd /
exec $TAIL_KAFKA_HOME/bin/kafka-run-class.sh kafka.tools.KafkaMigrationTool \
    --kafka.07.jar ../kafka-0.7.2.jar \
    --zkclient.01.jar ../zkclient-0.1.jar \
    --num.producers 16 \
    --num.streams $CONSUMER_THREADS \
    --consumer.config=../consumer.properties \
    --producer.config=../producer.properties \
    --whitelist="$TOPICS"
