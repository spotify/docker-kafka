# Kafka, Zookeeper and Kafka 7 proxy
FROM spotify/kafka

ADD kafka-0.7.2.jar kafka-0.7.2.jar
ADD zkclient-0.1.jar zkclient-0.1.jar
ADD consumer.properties consumer.properties
ADD producer.properties producer.properties
ADD start_proxy.sh /start_proxy.sh
ADD kafkaproxy.conf /etc/supervisor/conf.d/kafkaproxy.conf

ENV LOG_RETENTION_HOURS 1

ADD https://archive.apache.org/dist/kafka/0.8.1/kafka_2.8.0-0.8.1.tgz /
RUN cd / && tar xzf kafka_2.8.0-0.8.1.tgz
ENV TAIL_KAFKA_HOME /kafka_2.8.0-0.8.1

CMD ["supervisord", "-n"]
