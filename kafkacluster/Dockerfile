# Two-node Kafka Cluster and Zookeeper

FROM spotify/kafka

RUN ["rm", "-f", "/usr/bin/start-kafka.sh"]
ADD scripts/start-kafka.sh /usr/bin/start-kafka.sh
RUN ["chmod", "+x", "/usr/bin/start-kafka.sh"]

# Supervisor config
RUN ["rm", "-f", "/etc/supervisor/conf.d/kafka.conf"]
ADD supervisor/kafka1.conf supervisor/kafka2.conf /etc/supervisor/conf.d/

# 2181 is zookeeper, 9092, 9093 is two kafka brokers
EXPOSE 2181 9092 9093

CMD ["supervisord", "-n"]
