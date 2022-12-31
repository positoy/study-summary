# NCC

### n2c

- namespace & cluster 생성 필요 [pasta n2c](https://navertalk.pasta-dev.navercorp.com/ncc/)
- cluster 에 접근하기 위한 ncc 도구 설치 [n2c 도움말](https://pages.oss.navercorp.com/naver-container-cluster/docs/1/1.ncc/)

  ```bash
  $ mkdir ncc
  $ cd ncc
  $ wget -q http://registry.navercorp.com:80/dist/ncc/pkgs/ncc/linux-amd64/stable/ncc
  $ chmod 755 ncc
  $ ./ncc install
  $ ncc cluster set edu@ad1
  $ kubectl get pods
  
  $ ncc cluster ls
  $ ncc cluster set practice2@ad1
  $ ncc cluster current
  ```

### Habor Registry

- 프로젝트 생성 필요 [pasta harbor](https://navertalk.pasta.navercorp.com/harbor/)

- 프로젝트를 생성하면 rw 계정/비번 자동 생성

- dev/real 동일하게 reg.navercorp.com 사용

- 도커 이미지 올리기

  ```bash
  $ docker build -t hello:0.1 .
  $ docker tag hello:0.1 reg.navercorp.com/practice2/hello:0.1
  $ docker build -t reg.navercorp.com/practice2/hello:0.1 .
  $ docker push reg.navercorp.com/practice2/hello:0.1
  
  $ docker login (~/.docker/config.json)
  ```
  
- n2c 에서 도커 이미지 올리기

  - 자동으로 푸시 됨
  - ncc docker images 불가 ([PASTA harbor](https://navertalk.pasta.navercorp.com/harbor) 에서 확인 가능)
  - [ncc build 가이드](https://yobi.navercorp.com/n2c/posts/333)

  ```bash
  $ ncc build -t reg.navercorp.com/practice2/hello:0.3 
  ```

### Credential

2개의 인증키를 등록해야 함.
Yaml 이용한 Secret 생성으로 가능하지만, 웹으로 등록하면 다른 클러스터에도 자동 등록되고 CLI 에서도 사용 가능하므로, 웹 등록 추천.

1. OSS Github 인증
2. Harbor Docker Registry 인증



### Pipeline

- custom  (build) step
- image step
- deploy step



톡톡 pipeline

- node
- boot
- tomcat



