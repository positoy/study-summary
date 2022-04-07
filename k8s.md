# Docker

## minikube
- docker destop 은 유료화 되었지만, docker cli 에 minikube 로 구성된 k8s 클러스트 내부의 docker daemon 을 연결하면 기존처럼 사용가능하다.
- https://dhwaneetbhatt.com/blog/run-docker-without-docker-desktop-on-macos
  ```bash
  # Install hyperkit and minikube
  brew install hyperkit
  brew install minikube
  
  # Install Docker CLI
  brew install docker
  brew install docker-compose
  
  # Start minikube
  minikube start
  
  # Tell Docker CLI to talk to minikube's VM
  eval $(minikube docker-env)
  
  # Save IP to a hostname
  echo "`minikube ip` docker.local" | sudo tee -a /etc/hosts > /dev/null
  
  # Test
  docker run hello-world
  ```

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


