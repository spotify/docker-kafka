Kafka in Docker
===

This repository provides everything you need to run Kafka in Docker.

Why?
---
The main problem with running Kafka in Docker is that it depends on Zookeeper.
Compared to other Kafka docker images, this one runs both Zookeeper and Kafka
in the same container. This means:
* No dependency on an external Zookeeper host, or linking to another container
* Zookeeper and Kafka are configured to work together out of the box

In the box
---
* **spotify/kafka**

  The docker image with both Kafka and Zookeeper. Built from the `kafka`
  directory.

Build
---

    docker build -t spotify/kafka kafka/

Run
---

    docker run -P spotify/kafka

Notes
---
Things are still under development:
* Not particularily optimzed for startup time.
* Better docs
* We'd like to be able to configure more things.
* There should be a prober for Helios.

