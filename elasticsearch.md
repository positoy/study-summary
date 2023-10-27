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

2.2 구조개괄

# 엘라스틱서치 구조

- 인덱스 관점에서
  - shard : 문서를 나누어 저장한다
  - replication : shard 복제본
  - node(master, data, configuration) : 프로세스. 중복되지 않게 shard 를 담당하고, 데이터 RW, 클라이언트 응답 등 처리
  - cluster : 노드의 집합

# 루씬

- 문서 역색인 생성
- 생성된 역색인은
  - 메모리 버퍼에서 색인, 업데이트 삭제 되다가 (검색불가)
  - 주기적으로 디스크에 세그먼트 단위로 flush → paged → fsync → refresh (검색가능)
  - 엘라스틱서치/루씬 flush 는 다르다?!
  - 엘라스틱서치 flush/refresh 도 다르다?!

# 세그먼트

- 세그먼트 단위로 문서가 저장 됨
- 한번씩 세그먼트 병함

# 루씬/엘라스틱서치 인덱스

- 루씬 인덱스 = 루씬 세그먼트 x n
- 엘라스틱서치 샤드 = 루씬 인덱스 1개 랩핑
- 엘라스틱서치 인덱스 = 엘라스틱서치 샤드 x n
- 엘라스틱서치 인덱스는 클러스터 내 여러 노드에 분산돼있음

# translog

- 작업로그. 복구에 사용됨.
- 용량이 크면 안정성 크지만 복구 시간 오래 걸림. 적절한 용량 필요.
- 루씬 flush : segemnt (memory → disk)
- ES flush : translog (disk → empty)
- 엘라스틱서치 refresh = 루씬 flush
- 엘라스틱서치 flush = 루씬 commit

# 3. 인덱스설계

## 3.1 인덱스설정

- number_of_shards (기본값 1)
  - 문서를 통 몇개에 나눠 담을 것인가?
  - 샤드가 너무 많으면 클러스터 성능이 떨어짐 (색인 성능)
  - 샤드가 너무 적으면 장애시 복구 시간이 길어지고, 안정성이 떨어짐
  - 변경하려면 전체 다시 색인 필요 (reindex + replication 비용)
- number_of_replicas (기본값 1)
  - 복제본 (고가용성:HA)
  - 변경 가능
- refresh_interval (기본값 1s)
  - ES refresh = 루씬 flush
- index.search.idle.after (기본값 30s)
  - 일정시간 이상 쿼리가 없으면 refresh 멈춤

### 인덱스 (Shard & Replica)

- 삭제
  ```
  DELETE my_index
  ```
- 생성

```http
# request
PUT my_index
{
  "settings" : {
    "index" : {
      "number_of_shards" : "2",
      "number_of_replicas" : "2"
    }
  }
}
# response
{
  "acknowledged" : true, -- 인덱스가 생성 되었나
  "shards_acknowledged" : true, -- 요청한 수 만큼 샤드가 타임아웃 내에 생성 되었나
  "index" : "my_index"
}
```

- 수정

```
PUT my_index/_settings
{
  "settings" : {
    "index" : {
      "number_of_replicas" : "2"
    }
  }
}
```

### 인덱스 (mapping & field type)

- 매핑 (/my_index/\_mapping)
  - document 의 색인을 위한 메타정보
  - field type 한번 정해지면 변경 불가능
  - 동적/명시적 정의 가능
- 동적매핑 (dynamic mapping)
  - 인덱스 생성시 매핑정보를 명시하지 않으면, 문서를 보고 추론하여 매핑
  - 예기치 못한 신규 필드에 대응 가능
- 명시적매핑 (dynamic mapping)

  - 인덱스 생성시 매핑정보 명시
  - 잘 설계된 매핑은 운영,성능에 긍정적인 영향
  - 생성

    - 인덱스 생성시

    ```
    PUT mapping_test
    {
      "settings" : {
        "index" : {
          "number_of_shards" : "2",
          "number_of_replicas" : "2"
        }
      },
      "mappings" : {
        "properties" : {
          "created" : {
            "type":"date",
            "format":"strict_date_time||epoch_millis"
          }
        }

      }
    }
    ```

    - 기존 인덱스에 추가

    ```
    PUT my_mapping/_mapping
    {
      "properties":{
        "longValue":{
          "type":"long"
        }
      }
    }
    ```

    - 필드 타입
      3가지 종류
      - simple : text, keyword, date, long, double, boolean, ip 등
        - scaled_float : scaling_factor 를 100 으로 지정하면, 394를 3.94 로 취급하여 디스크 공간 이득을 볼 수 있음
        - date : Java DateTimeFormatter 로 인식 가능한 패턴 사용 가능
      - 계층구조 지원 : object, nested
      - 특수 : geo_point, geo_shape

# 4. 데이터다루기

## 4.1. 단건문서

### 4.1.1. 색인 API

PUT {my_index}/\_doc/{id}?routing={routingKey}

### 4.1.2. 조회 API

GET {my_index}/\_doc/{id}?routing={routingKey}

- id 로 문서를 조회할 때에는 역색인이 필요치 않다.
- refresh 전에도 translog 에서 조회 가능하다.
- id 를 안다면 검색보다 조회 API 가 성능이 좋으며 빠르게 검색 가능하다.

GET {my_index}/\_source/{id}?routing={routingKey}

- source 조회하면 메타데이터가 제외된다.

GET {my_index}/\_doc/{id}?routing={routingKey}&\_source_includes=p\*,views

- response
  {
  ...
  "source" : {
  "public" : true,
  "views" : 10,
  "point" : 4.5
  }
  }

GET {my_index}/\_doc/{id}?routing={routingKey}&\_source_includes=p\*,views&\_source_excludes=public

- response
  {
  ...
  "source" : {
  "views" : 10,
  "point" : 4.5
  }
  }

### 4.1.3. 업데이트 API

1. doc
   POST {my_index}/\_update/{id}
   {
   "doc" : {
   <!-- content to be updated -->
   }
   }

- source 가 있어야 update 가능
- 기존 세그먼트를 삭제하고 새로운 세그먼트로 저장된다.
- 변경할 것이 없으면 수행하지 않고 "noop" result 반환

2. doc_as_upsert
   POST {my_index}/\_update/{id}
   {
   "doc":{
   <!-- content to be updated -->
   },
   "doc_as_upsert" : true
   }

- 기존 내용이 없으면 실패

3. script
   POST {my_index}/\_update/{id}
   {
   "script":{
   "source": "ctx.\_source.views += params.amount",
   "lang": "painless",
   "params": {
   "amount": 1
   }
   },
   "scripted_upsert" : false
   }

- ES 에서 개발한 painless 언어 이용하여 script 정의

### 4.1.4. 삭제 API

DELETE {my_index}/\_doc/{id}

## 4.2. 복수문서

### 4.2.1. bulk API

- post Body 에 복수 요청을 한번에 보낼 수 있음
- 200 응답을 받더라도 개별 요청은 실패할 수 있다.
- post body 에 기재된 요청은 여러 샤드에서 분산되어 실행될 수 있으므로 순서대로 실행이 보장되지 않는다. id, routing 조건이 기재되면 보장할 수 있음

POST \_bulk
{"index":{"\_index":"my_index", "\_id":"hello"}}
{"field1":"hello"}
{"index":{"\_index":"my_index", "\_id":"world", "routing":"a"}}
{"field1":"world"}
{"delete":{"\_index":"my_index", "\_id":"hello"}}
{"update":{"\_index":"my_index", "\_id":"world"}}
{"doc":{"field1":"world2"}}

POST my_index/\_bulk
{"index":{"\_id":"hello"}}
{"field1":"hello"}
{"index":{"\_id":"world", "routing":"a"}}
{"field1":"world"}
{"delete":{"\_id":"hello"}}
{"update":{"\_id":"world"}}
{"doc":{"field1":"world2"}}

### 4.2.2. mutli get API

여러 문서를 동시에 조회할 수 있음

GET \_mget
{
"docs" : [{
"\_index" : "my_index",
"\_id" : "SoP--IoB11Ip35zxZEvs",
"routing":"SoP--IoB11Ip35zxZEvs"
},{
"\_index" : "my_index",
"\_id" : "S4P--IoB11Ip35zxZUuJ",
"\_source" : {
"include":["f*"]
}
}]
}

GET my_index/\_mget
{
"ids":["SoP--IoB11Ip35zxZEvs","S4P--IoB11Ip35zxZUuJ"]
}

### 4.2.3. update/delete by query

잘 안쓸듯

## 4.3. 검색 API

GET my_index,your_index/\_search

GET my_index/\_search
{
"query":{
"match":{
"title":"hello"
}
}
}

GET my_index/\_search?q=title:hello

GET my_index/\_search?q=date:{0to20]

GET my_index/\_search?q=title:\*ello

- \*는 검색어 처음에 들어오지 않도록 조심해야 함. 전체 term 검색하기 때문.
- search.allow_expensive_queries 설정에서 막을 수 있음

### 4.3.4. match 쿼리

GET [my_index/]\_search
{"query":{"match":{"fieldName":{"query":"test query sentence"}}}}

검색어도 아날라이저로 분석되어 각 토큰의 쿼리가 OR 로 결합된다.
다음처럼 결함 연산을 AND 로 변경할 수 있다.
{"query":{"match":{"fieldName":{"query":"test query sentence", "operator":"and"}}}}

### 4.3.5. term 쿼리

정확히 일치하는 문서를 검색한다. (keyword)
아날라이저가 적용되진 않지만 필터와 노멀라이저는 적용된다.

### 4.3.6. terms 쿼리

질의어 여러개 term 검색 OR operator 적용
GET [my_index/]\_search
{"query":{"terms:{"fieldName":["hello","world]}}}

### 4.3.7. range 쿼리

범위 검색. 날짜의 경우 간단한 연산 사용 가능하다.
+36h/d : 36시간을 더하고, 날짜 이하의 시간은 버림한다.

GET [my_index/]\_search
{"query":{"terms:{"dateField":{"gte":"2019-10-10T10:00:00.000Z||+36h/d","lt":"now-3h/d"}}}}

### 4.3.8. prefix

### 4.3.9. exists

### 4.3.10. bool

- must vs filter : 조건에 맞는 것을 AND 로 선별. filter 는 점수화하지 않음
- should : OR 연산. minimum_should_match 를 만족해야 함
- must_not : 최종 검색 결과에서 제외. 점수화하지 않음

### 쿼리문맥, 필터문맥

query context : 유사도 점수로 평가
filter context : true/false 평가

### 쿼리수행순서

search
query context
filter context
sort
pagination

## 4.4. 단건문서

## 4.5. 단건문서
