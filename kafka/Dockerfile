# Kafka and Zookeeper

FROM java:openjdk-8-jre

ENV DEBIAN_FRONTEND noninteractive
ENV SCALA_VERSION 2.11
ENV KAFKA_VERSION 0.11.0.1
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"

# Install Kafka, Zookeeper and other needed things
RUN apt-get update && \
    apt-get install -y zookeeper wget supervisor dnsutils && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    wget -q http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz && \
    tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt && \
    rm /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz

ADD scripts/start-kafka.sh /usr/bin/start-kafka.sh

# Supervisor config
ADD supervisor/kafka.conf supervisor/zookeeper.conf /etc/supervisor/conf.d/

# 2181 is zookeeper, 9092 or 9093 is kafka
# Because of Kafka metadata announcement, the internal port must be equal to the mapped external port.
# In development environment, multiple Kafkas must be mapped to different ports.
# So, we expose all ports that are used in any of our Kafka instances.
# A Kafka container will be configured to bind to its port via a mounted config file.
# The other exposed Kafka ports are not bound by the container and cannot be connected.
# This is a pretty ugly hack but fits best into our deploy environment.
# Other possible hacks are even worse.
EXPOSE 2181 9092 9093

CMD ["supervisord", "-n"]
