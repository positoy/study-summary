# kafka

### 참고자료

- https://www.youtube.com/watch?v=geMtm17ofPY kafka 조금 아는 척 하기
- https://www.youtube.com/watch?v=waw0XXNX-uQ&list=PL3Re5Ri5rZmkY46j6WcJXQYRlDRZSUQ1j 데브원영 Kafka

### broker

- zookeeper 로 broker 간 설정을 공유
- kafka manager 로 설정 변경 가능
- topic 으로 메시지 큐를 제공
- 2개 이상의 broker 로 클러스터 구성. HA 확보
- 3개 이상의 partition 으로 produce/consumer 처리량 증가 (보통 홀수로 구성)
- topic 리더/팔로워 설정하여 다른 파티션에 데이터가 동기화되는 레플리카 구성.
- 토픽의 리더와 팔로워 상태가 동기화된 상태를 ISR(In-Sync Replica) 라고 함.
- 나중에 topic 의 partition 수, replica-factor 등 변경 및 재배치 가능

### producer

![image](https://user-images.githubusercontent.com/7664099/154040300-255b77db-6050-49a7-8fc8-e2d98584df3b.png)

- send(topic, key, value) 로 메시지 발송

- key 가 null 인 경우 라운드로빈으로 파티션 결정

- key 가 고정된 경우 항상 동일한 파티션에 produce 하여, 해당 키에 대해서 순서가 보장됨

- key, value 의 serializer 설정 가능

- 전송결과 확인

  - 확실하게 전송하기 (배치 사용 불가. 처리량 저하)

    ```java
    Future<RecordMetadata> f = producer.send(new ProducerRecord<>("topic", "value"));
    try {
      RecordMetadata meta = f.get(); 
    } catch (ExecutionException ex) {
      // 전송실패처리
    }
    ```

  - 빠르게 전송하기 (배치 사용. 처리량 저하 없음)

    ```java
    producer.send(new ProducerRecord<>("simple", "value"),
                  new Callback() {
                    @Override
                    public void onCompletion(RecordMetadata metadata, Exception ex) {
                      
                    }
                  });
    ```

- 처리량
  - `batch.size` 배치크기. 배치가 다 차면 전송
  - `linger.ms` : 전송 대기 시간. 대기 시간이 없으면 배치가 차지 않아도 전송.
- 전송보장
  - `ack = 0` : ack 기다리지 않음. 전송 보장되지 않음.
  - `ack = 1` : 파티션 리더에 저장되면 ack 받음. 리더가 장애시 메시지 유실 가능.
  - `ack = all` : 레플리카에 저장되면 ack 받음. (min.insync.replicas 설정 참조)
    - 브로커 옵션인 `min.insync.replicas` 의 수 만큼 replicas 에 저장되면 ack 응답.
    - `min.insync.replicas` 를 레플리카 수로 지정하면 하나의 레플리카라도 장애가 나면 전송 실패하므로 작게 설정해야 함.

-  에러유형
  - 전송전 : serialize 실패, producer 설정 크기제한 초과, buffer 대기 시간 초과
  - 전송과정 : 전송타임아웃, send 크기 제한 초과 , 리더 다운으로 새 리더 선출중
- 에러대응
  - 재시도 (절대로 무한 재시도 x)
    - 재시도 주의사항 : 중복전송, 순서바뀜
      - 중복 전송의 결과가 idempotent 하도록 설계
      - 기록의 순서가 변경될 수 있음. `max.in.flight.requests.per.connection=1` 설정시 순서 보장
  - 기록 (추후 재처리)

### comsumer

- #파티션 > #컨슈머

  - #파티션 > 컨슈머이면 노는 컨슈머가 발생

- 커밋 오프셋

  - 어디까지 읽고(current offset), 어디까지 처리했는지를 나타냄(commit offset)
  - 컨슈머 그룹의 커밋 오프셋이 없는 경우
    - `auto.offset.reset = earliest` : 맨 처음 오프셋 사용
    - `auto.offset.reset = latest` : 가장 마지막 오프셋 사용 (기본값)
    - `auto.offset.reset = none` : 익셉션 발생

- 자동커밋/수동커밋

  - `enable.auto.commit` 일정 주기로 컨슈머가 읽은 오프셋을 커밋. 기본값 true

  - `auto.commit.interval.ms` 자동 커밋 주기

  - poll(), close() 호출시 자동 커밋 실행

  - 수동커밋 시 예외처리

    - commitSync

      ```java
      ConsumerRecords<String, String> records = consumer.poll(Duration.ofSeconds(1));
      try {
        consumer.commitSync();
      } catch (Exception ex) {
        // 예외처리
      }
      ```

    - commitAsync

      ```java
      consumer.commitAsync(callback); // callback 에서 예외처리
      ```

- 컨슈머 설정

  - `fetch.min.bytes` 브로커가 전송할 최소 데이터 크기. 기본값 1
  - `fetch.max.wait.ms` : 데이터가 최소 크기가 될 때까지 기다릴 시간. poll 대기시간과 다름. 기본값 500.
  - `max.partition.fetch.bytes` : 파티션당 서버가 리턴할 수 있는 최대 크기. 기본값 1048576 (1MB)

- 재전송과 순서에 주의

  - 재전송 : `A 게시물 좋아요` → `A 게시물 유저 B 가 좋아요`
  - 순서 : timestamp 활용

- 브로커와 컨슈머의 연결끊김이 감지되면 리밸런스

  - `session.timeout.ms` : 세션 타임아웃 시간. 기본값 10초
  - `heartbeat.interval.ms` : 하트비트 전송 주기. 기본값 3초. `session.time.out.ms`의 1/3 이하 추천.
  - `max.poll.interval.ms` : poll 메서드의 최대 호출 간격

- 스레드

  - KafkaConsumer 메소드는 thread-safe 하지 않음

  - 단, loop 를 빠져나올 때에는 다른 스레드에서 wakeup() 호출할 수 있음

    ```java
    try {
      while (true) {
        // 다른 스레드에서 wakeup 호출해주면 WakeupException 발생
        ConsumerRecords<String,String> records = consumer.poll(Duration.ofSeconds(1));
        // process record
        try {
          consumer.commitAsync();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    } catch (Exception ex) {
      ...
    } finally {
      consumer.close();
    }
    ```


### API

- Connect API
- Streams API

### Getting started

```bash
wget https://www.apache.org/dyn/closer.cgi?path=/kafka/2.7.0/kafka_2.13-2.7.0.tgz
tar -xzf kafka_2.13-2.7.0.tgz
cd kafka_2.13-2.7.0

### start server
bin/zookeeper-server-start.sh config/zookeeper.properties
bin/kafka-server-start.sh config/server.properties

### create a topic
bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092

### write events
bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092

### read events
bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092

### terminate
rm -rf /tmp/kafka-logs /tmp/zookeeper
```



### Concepts

- broker
  - 보통 3개 이상의 broker 구성 (partition 1, replication 3)
  - ISR (In Sync Replica) : 1 leader partition, 2 follower partition
  - ack
    - 0 저장을 보장하지 않음. 속도가 빠름
    - 1 leader patition 에 저장을 보장
    - all 모든 partition 에 저장을 보장. 속도가 느림.
- producer
  - key 가 없으면 라운드 로빈으로 partition을 지정하여 저장
  - key 가 있으면 hash 값 기반으로 동일한 partition 에 record 저장 (파티션을 추가하면 변경됨)
- consumer
  - partition에서 Record polling
  - offset commit
  - consumer gorup 으로 병렬처리 (#consumer < #partition)
    - consumer group
    - auto.offset.reset=true (새로운 consumer 그룹이 record를 0번부터 가져가게 됨)
- [Topics](https://kafka.apache.org/documentation/#intro_concepts_and_terms)
- Partition
  - log.retention.ms : record 최대 보존시간
  - log.retention.byte : record 최대 보존크기
- Messages



### APIs

- admin : 현재 상태 확인 등

- producer : 이벤트 메시지 생성

  ```java
   Properties props = new Properties();
   props.put("bootstrap.servers", "localhost:9092");
   props.put("acks", "all");
   props.put("retries", 0);
   props.put("linger.ms", 1);
   props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
   props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
  
   Producer<String, String> producer = new KafkaProducer<>(props);
   for (int i = 0; i < 100; i++)
       producer.send(new ProducerRecord<String, String>("my-topic", Integer.toString(i), Integer.toString(i)));
  
  ```

  

- consumer : 이벤트 메시지 수신

  ```java
  Properties props = new Properties();
  props.setProperty("bootstrap.servers", "localhost:9092");
  props.setProperty("group.id", "test");
  props.setProperty("enable.auto.commit", "true");
  props.setProperty("auto.commit.interval.ms", "1000");
  props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
  props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
  KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
  consumer.subscribe(Arrays.asList("foo", "bar"));
  while (true) {
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
    for (ConsumerRecord<String, String> record : records)
      System.out.printf("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value());
  }
  ```

  ```java
  TopicPartition partition0 = new TopicPartition(topicName, 0);
  TopicPartition partition1 = new TopicPartition(topicName, 1);
  consumer.assign(Arrays.asList(partition0, partition1));
  ```

  

- streams : real time 으로 kafka message 를 처리할 수 있음

- connect : 기존 db 데이터를 카프카에 입력하거나, 카프카 데이터를 db에 저장할 때 사용

