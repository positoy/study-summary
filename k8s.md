# Docker

## kafka

```bash
git clone https://github.dev/bitnami/bitnami-docker-kafka
# [kafka 외부 client 접근 허용하기](https://github.com/bitnami/bitnami-docker-kafka#accessing-apache-kafka-with-internal-and-external-clients)
vim bitnami-docker-kafka/docker-compose.yml 
docker-compose up -d

wget https://dlcdn.apache.org/kafka/3.1.0/kafka_2.13-3.1.0.tgz
tar xvf kafka_2.13-3.1.0.tgz
cd kafka_2.13-3.1.0

# topic 생성
bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9093
# produce
bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9093
# consume
bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9093
```


