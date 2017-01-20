#!/bin/bash

set -o errexit
set -o nounset

set_setting() {
  name=$1
  value=$2
  file="$KAFKA_HOME/config/server.properties"

  sed -r -i "s/^[#\\s]*($name)[\\s]*=.*/\\1=$value/" "$file"
  if grep -Pq "^$name=$value\$" "$file"; then
    echo "$name: updated to '$value'"
  else
    echo "$name=$value" >> "$file";
    echo "$name: added and set to '$value'"
  fi
}

env | grep -Po '(?<=^KAFKA_CONFIG_).*' | while IFS='=' read -r name value; do
  set_setting "$(echo "${name//_/.}" | tr '[:upper:]' '[:lower:]')" "$value"
done

# Configure advertised host/port if we run in helios
if [ -n "${HELIOS_PORT_kafka:-}" ]; then
    set_setting advertised.host.name "$(echo "$HELIOS_PORT_kafka" | cut -d':' -f 1 | xargs -n 1 dig +short | tail -n 1)"
    set_setting advertised.port "$(echo "$HELIOS_PORT_kafka" | cut -d':' -f 2)"
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

    set_setting zookeeper.connect "$ZK_CHROOT"
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
