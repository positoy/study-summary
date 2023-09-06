# ElasticSearch

### 설치

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.4.2-darwin-x86_64.tar.gz
tar zxvf elasticsearch-8.4.2-darwin-x86_64.tar.gz
ln -s elasticsearch-8.4.2 elasticsearch

# 클러스터/서버 이름, 데이터/로그 저장위치, 호스트ip 등 설정
code elasticsearch/config/elasticsearch.yml
# JVM 메모리 설정
code elasticsearch/config/jvm.options
```

### 실행&종료

```bash
# 실행
elasticsearch/bin/elasticsearch -d -p elasticsearch/es.pid
# 동작확인
curl -XGET http://localhost:9200
# 종료
kill -SIGTERM `cat elasticsearch/es.pid`
```

# Kibana

### 설치

```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.4.2-darwin-x86_64.tar.gz
tar zxvf kibana-8.4.2-darwin-x86_64.tar.gz
ln -s kibana-8.4.2 kibana

# port, host, publicBaseUrl, hosts 설정
code kibana/config/kibana.yml
```

### 실행&종료

```bash
# 실행
kibana/bin/kibana
# 동작확인
http://localhost:5601
```

# Cerebro

### 설치

```bash
wget https://github.com/lmenezes/cerebro/releases/download/v0.9.4/cerebro-0.9.4.zip
unzip cerebro-0.9.4.zip
ln -s cerebro-0.9.4 cerebro
```

### 실행&종료

```bash
# 실행
bundled_jvm="elasticsearch/jdk.app/Contents/Home/" \
JAVA_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/sun.net.www.protocol.file=ALL-UNNAMED" \
cerebro/bin/cerebro

# 동작확인
http://localhost:9000
```

# ES CRUD

```http
<!-- 문서추가 -->
PUT my_index/_doc/2
{
    "title":"hello world",
    "views":1234,
    "public":true,
    "created":"2023-09-05T20:24:01.234Z"
}

<!-- 문서추가 -->
POST my_index/_doc
{
    "title":"hello world",
    "views":1234,
    "public":true,
    "created":"2023-09-05T20:24:01.234Z"
}

<!-- 문서조회 -->
GET my_index/_doc/2

<!-- 문서업데이트 -->
POST my_index/_update/2
{
  "doc" : {
    "yello" : "world"
  }
}

<!-- 문서검색 -->
GET my_index/_search
{
  "query" : {
    "match" : {
      "title" : "hello world"
    }
  }
}

<!-- 문서삭제 -->
DELETE my_index/_doc/BUglZYoBcfeNiXn4XiLl

```
