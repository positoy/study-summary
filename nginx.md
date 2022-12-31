# Nginx



### 설치

```bash
brew install nginx
brew services start nginx
```



### 명령어

```bash
nginx -h
nginx -v 
nginx -V
nginx -t
nginx -T
nginx -s start,quit,reload,reopen
```



## 부하분산

### web server (static)

#### http

- upstream
  - weight 비중으로 로드밸런싱. 생략하면 1
  - 모든 업스트림이 연결되지 않으면 backup 사용
- server
  - listen 80 default_server; 사용시 server_name 생략 가능
  - server_name 으로 요청의 host 확인
  - proxy_pass 에 upstream 지정하여 로드밸런싱

```
http {

	upstream marketing_api {
		server xvmapi01-bzt.nfra.io:10220 weight=1;
    server xvmapi02-bzt.nfra.io:10220 weight=2;
    server xvmapi03-bzt.nfra.io:10220 backup;
	}

	server {
    listen  80;

    server_name
             api-marketing.talk.naver.com
         dev-api-marketing.talk.naver.com
        beta-api-marketing.talk.naver.com
    ;

    if ($time_iso8601 ~ "^(?<yymmdd>\d{4}-\d{2}-\d{2})") {}
    access_log  /home1/irteam/apps/nginx/logs/marketing_api.access.log.$yymmdd  main;

    client_max_body_size  40m;

		location / {
      allow 10.0.0.0/8;
      deny  all;
      proxy_pass  http://marketing_api;
      proxy_set_header  Host               $host;
      proxy_set_header  X-Real-IP          $remote_addr;
      proxy_set_header  X-Forwarded-For    $proxy_add_x_forwarded_for;
      proxy_set_header  X-Forwarded-By     $server_addr;
      proxy_set_header  X-Forwarded-Proto  $scheme;
      proxy_set_header  X-Forwarded-Port   $server_port;
    }
	}	
}
```



#### stream (tcp)

- upstream
  - Mysql 요청을 2개의 replica 로 분산
  - 2 개 replica 가 모두 다운되면 backup 사용
- server

```
stream {

	upstream mysql_read {
    server read1.example.com:3306		weight=2;
    server read2.example.com:3306;
    server 10.10.12.34:3306					backup;
	}
	
	server {
    listen 3306;
    proxy_pass mysql_read;	
	}

}
```



#### stream (udp)

```
stream {
	upstream ntp {
		server ntp1.example.com:123		weight=2;
		server ntp2.example.com:123;	
	}
	
	server {
		listen 123 udp;
		proxy_pass ntp;
	}
}
```



#### 부하분산 알고리즘

- 라운드로빈 (기본값)
- 최소연결 (least_conn)
- 최소시간 (least_time) : header vs last_byte / nginx plus only.
- 제네릭해시 (hash) : 업스트림 풀이 수정되면 처리된 요청이 재분배됨 주의
- 아이피해시 (ip_hash) : 세션관리가 필요 없거나, 세션이 공유 메모리로 관리되지 않는 경우 유용. http only.

```
upstream backend {
	least_conn;
	server server1.example.com		weight=2;
	server server2.example.com;
	server server3.example.com		backup;	
}
```



#### 헬스체크

- 실패에 대한 매개변수를 정의하기
- max_fails (기본값 1)
- fail_timeout (기본값 10s)

```
upstream backend {
	server server1.example.com		max_fails=3	fail_timeout=3s;
	server server2.example.com		max_fails=3	fail_timeout=3s;
}
```

- 에러가 발생하는 경우 다음 upstream 에 대해 시도
- tries 횟수 만큼 다음 upstream 에 시도

```
http {
	proxy_next_upstream  error  timeout  http_502  http_503;
	proxy_next_upstream_tries  5;
}
```



## 트래픽관리

#### A/B 테스트

```
http {	
    split_clients "${date_gmt}" $root_folder {
        50%		"html";
        *			"html2";
    }

    server {
        listen 80;
        root $root_folder;
        location / {
            index index.html;
        }
    }
}
```



#### 연결제한

- ip 주소를 key 로 사용하여 메모리를 10Mb 로 제한
- 요청이 프록시를 거쳐 인입될 경우 모든 요청이 거절될 위험이 있음 (geoip_proxy_recursive 등을 사용하여 헤더의 Forwarded 정보를 이용하여 사용자 ip 를 찾고 적용해야 함)

```
http {
	limit_conn $binary_remote_addr zone=limitbyaddr:10m;
  limit_req_status 429;

	server {
        listen       8080;
        server_name  localhost;
        limit_conn limitbyaddr 40;
	}
}
```



#### 연결빈도제한

- 초당 3회 이상 접근 제한
- burst, delay 변수를 이용하여 상세한 접근제한 가능
- 연결제한과 마찬가지로 키값에 주의

```
http {
	limit_req_zone $binary_remote_addr zone=limitbyaddr:1m rate=3r/s;
  limit_req_status 429;

	server {
        listen       8080;
        server_name  localhost;
        limit_req zone=limitbyaddr;
#        limit_req zone=limitbyaddr burst=12 delay=9;
	}
}
```



#### 대역폭제한

- 10m 를 다운 받았으면 이후로는 초속 1m 로 전달

```
location /download/ {
	limit_rate_after 10m;
	limit_rate 1m;
}
```

gid
