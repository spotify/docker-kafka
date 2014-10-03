# Kafka and Zookeeper

FROM dockerfile/java:oracle-java7

MAINTAINER Marc Bruggmann <marcbr@spotify.com>

ENV DEBIAN_FRONTEND noninteractive

# Install Kafka, Zookeeper and other needed things
RUN apt-get update && \
    apt-get install -y zookeeper wget supervisor dnsutils && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q http://mirror.gopotato.co.uk/apache/kafka/0.8.1.1/kafka_2.8.0-0.8.1.1.tgz -O /tmp/kafka_2.8.0-0.8.1.1.tgz && \
    tar xfz /tmp/kafka_2.8.0-0.8.1.1.tgz -C /opt && \
    rm /tmp/kafka_2.8.0-0.8.1.1.tgz

ENV KAFKA_HOME /opt/kafka_2.8.0-0.8.1.1
ADD start-kafka.sh /usr/bin/start-kafka.sh

# Supervisor config
ADD supervisor-kafka.conf /etc/supervisor/conf.d/kafka.conf
ADD supervisor-zookeeper.conf /etc/supervisor/conf.d/zookeeper.conf

# 2181 is zookeeper, 9092 is kafka
EXPOSE 2181 9092

CMD ["supervisord", "-n"]
