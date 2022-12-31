# Step01. 컨테이너 첫걸음

```bash
docker run hello-world
docker pull centos:7
docker images
docker run -it --name test1 centos:7 bash
docker ps -a
docker logs 
docker commit
docker login
docker push
```



# Step02. 컨테이너 다루기

```bash
# ~/.kube/config 의 내용을 보여주어 현재 kubectl 이 명령하는 대상 클러스터 정보 표시
kubectl config use-context minikube
kubectl config get-context
kubectl config view

# 오브젝트 작성 및 적용
kubectl create|apply|replae -f manifest.yml
kubectl delete manifest.yml
- kubectl delete po nginx
- kubectl delete deploy web-deploy
- kubectl delete service webservice

# docker
docker run hello-world
docker ps
docker ps -a
docker images

docker rm 

docker run --name hello-world hello-world
docker rm hello-world
docker rmi hello-world

docker run --name nginx -p 80:80 nginx 
kubectl cluster-info
curl 192.168.59.103

docker run --name nginx2 -p 80:80 -d nginx
curl 192.168.59.103

docker logs nginx2
docker exec -it nginx2 bash
docker exec -it nginx2 bash -c "tail -f /var/log/nginx/error.log"

docker stop/kill

docker run -it --name ubuntu ubuntu bash

docker stop/kill

docker logs ubuntu // exited by "enter exit" or "stop"
docker logs ubuntu2 // exited by kill

docker start
```

# Step03. 컨테이너 개발

```bash
# docker commit
docker run --name ubuntu-git -it ubuntu bash
apt update
apt install git openjdk-8-jdk maven -y
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
docker commit 15526873d1cd ubuntu-git:0.1

docker images
docker run -it ubuntu-git:0.1 -p 80:10950 bash
mkdir /app
git clone https://oss.navercorp.com/navertalk/bizmarketing /app
cd /app
./gradlew clean :bizmarketing-api:bootJar
java -jar /app/bizmarketing-api/build/libs/bizmarketing-api-0.0.1-SNAPSHOT.jar
curl http://192.168.59.103/marketing/friendcount/PLACE/1054756166\?channelFilterType\=RECENT_CUSTOMER -H "X-Naver-Client-Id: talkmarketing_20211116"

docker commit eef03a5849e0 ubuntu-git:0.2
docker run -d -p 80:10950 ubuntu-git:0.2 bash -c "java -jar /app/bizmarketing-api/build/libs/bizmarketing-api-0.0.1-SNAPSHOT.jar"

# dockerfile
FROM openjdk:8
WORKDIR /app/bizmarketing-api
COPY ./bizmarketing-api/build/libs/*.jar .
ENTRYPOINT ["bash", "-c", "java -jar /app/bizmarketing-api/*.jar"]

docker build -t bizmarketing .
docker run -d -p 80:10950 bizmarketing
curl http://192.168.59.103/marketing/friendcount/PLACE/1054756166\?channelFilterType\=RECENT_CUSTOMER -H "X-Naver-Client-Id: talkmarketing_20211116"

# ncc springboot
https://oss.navercorp.com/navertalk/ncc/blob/master/docker/apps/boot/Dockerfile
```



### [dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

- Create ephemeral containers : 재시작해도 문제가 없게 만들자!

  - 가능하면 Read Layer 만 사용
  - 하나의 프로세스만 (Decouple applications) : 수정하기 쉽고, horizontal scaleable 하게.

- Understand build context : Dockerfile 의 위치에 따라서 결과가 달라진다.

  - 빌드할 때 context 를 데몬에게 전달한다.
  - 컨텍스트를 지정할 수 있다. `docker build -t myimage:v1 -f ./Dockerfile ./contextDirectory`
  - 불필요한 파일은 context에서 제외하자. `.dockerignore`

- Use multi-stage builds : 빌드 layer 를 나누어 캐시를 활용하고, 빌드 시간과 이미지 용량을 줄이자.

  - 캐시를 고려하여 작성

    ```dockerfile
    // image1
    FROM ubuntu:18.04
    RUN apt-get update
    RUN apt-get install -y curl
    
    // image2 - image2 의 2번째를 재활용함
    FROM ubuntu:18.04
    RUN apt-get update
    RUN apt-get install -y curl nginx
    
    // 수정
    FROM ubuntu:18.04
    RUN apt-get update && apt-get install -y curl nginx
    ```

  - 소스코드를 포함한 이미지 (1.17GB)

    ```dockerfile
    FROM openjdk:8
    COPY . /apps/bizmarketing
    WORKDIR /apps/bizmarketing
    RUN ./gradlew clean :bizmarketing-api:bootJar
    ENTRYPOINT java -jar /apps/bizmarketing/bizmarketing-api/build/libs/bizmarketing-api-0.0.1-SNAPSHOT.jar
    ```

  - 소스코드를 제외한 이미지 (587MB)

    ```dockerfile
    FROM openjdk:8 AS build
    COPY . /apps/bizmarketing
    WORKDIR /apps/bizmarketing
    RUN ./gradlew clean :bizmarketing-api:bootJar
    
    FROM openjdk:8
    COPY --from=build /apps/bizmarketing/bizmarketing-api/build/libs/bizmarketing-api-0.0.1-SNAPSHOT.jar /apps/bizmarketing-api/
    ENTRYPOINT ["bash", "-c", "java -jar /apps/bizmarketing-api/*.jar"] // sh 쉘은 *가 동작하지 않음
    ```

  - Using pipes : | 명령이 기대와 다르게 동작함

    - (alpine 기준) sh 스크립트가 실행되고, 파이프 앞의 명령이 항상 성공 → `set -o pipefail &&` 을 앞에 붙이기
    - 마찬가지로, `java -jar *.jar` 도 실패 → `ENTRYPOINT ["bash", "-c", "java -jar /apps/bizmarketing-api/*.jar"]

# Step04. 컨테이너와 네트워크

```bash
# --link {containerName}
- 이미지를 run 할 때, 다른 컨테이너에 접근을 설정할 수 있음 
  `docker run -d -p 80:80 --link db wordpress`
- 하지만 --link 는 없어질 예정이므로 아래 network 사용


# network
docker network (create|ls|inspect|rm|connect|disconnect)
- 이미지를 run 할 때, 컨테이너 간 접근을 위해 네트워크를 설정할 수 있음
  `docker network create my-network`
  `docker run --network my-network mysql`
  `docker run --network my-network wordpress` // mysql 컨테이너으 모든 포트에 접근 가능
- bridge 네트워크는 외부 네트워크(인터넷)과의 연결이며 기본으로 enable 되어있음
  - 하지만 포트는 닫혀있어서, 이미지 run 할 때 열 포트를 명시해줘야 함
    `docker run -p 80:8080 wordpress`
```

# Step05. 컨테이너 API

- 종료요청 API
  
  - script.sh
  
    ```bash
    #!/bin/sh
    
    BACKUP=/docs/backup
    
    count=1
    if [ -f $BACKUP ]; then
        echo 'reload backup to count'
        count=$(cat $BACKUP)
    fi
    
    save() {
        echo 'save count to backup'
        echo $count >$BACKUP
        exit 0
    }
    
    trap save TERM
    
    while true; do
        echo $count
        count=$((count + 1))
        sleep 1
    done
    ```
  
  - Dockerfile
    ```dockerfile
    FROM alpine:latest
    WORKDIR /app
    COPY ./script.sh /app
    ENTRYPOINT "/app/script.sh"
    ```
  
  - docker
    ```bash
    docker build -t alpine-echo:v3 .
    mkdir docs
    
    ### docker 실행
    docker run  -it --rm -v `pwd`/docs:/docs --name alpine-echo alpine-echo:v3
    
    ### docker 종료(docs/backup 에 카운트 저장)
    docker stop alpine-echo
    
    ### docker 실행 (docs/backup 에서 카운트 로드)
    docker run  -it --rm --volume `pwd`/docs:/docs --name alpine-echo alpine-echo:v3
    ```
  
- 퍼시스턴트볼륨 API

  - --volume {hostsDir}:{containerDir}
  - -v {hostsDir}:{containerDir}

- 로그/백그라운드

  ```bash
  #컨테이너를 백그라운드로 실행하기
  docker run -d --name {containerName} {image}
  
  #백그라운드로 실행중인 컨테이너의 로그 보기
  docker logs -f {containerName}
  ```



## Step06. 쿠버네티스 첫걸음

### minikube

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



- 쿠버네티스 명령 [docs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)

```bash
# 클러스터 정보
kubectl cluster-info
kubectl get node

# 파드 직접 실행
kubectl run hello-world --image=hello-world --rm -it --restart=Never|Always|OnFailure
kubectl get pod
kubectl delete pod hello-world

# 파드 컨트롤러 실행 (restart Always)
kubectl create deployment nginx --image=nginx --replicas=3
watch -n 0.1 "kubectl get deployment,po"
kubectl delete pod/nginx-85b98978db-pbsk2
kubectl delete deployment nginx

# 잡 컨트롤러 실행 (restart OnFailure)
kubectl create job hello-world --image=ubuntu
-- /bin/bash -c "date; echo 'hello-world'; sleep 10; date; exit 1;" // restart OnFailure
```



## Step07. 메니페스트와 파드

### Docker 이미지 만들기 & Registry 등록

- `ticktok.sh`

  ```bash
  #!/bin/sh
  while (true); do
      sleep 1
      echo "<h1>$(date)</h1>" >/usr/share/nginx/html/index.html
  done
  ```

- `Dockerfile`

  ```bash
  FROM alpine
  COPY ./ticktok.sh /
  RUN chmod +x /ticktok.sh
  ENTRYPOINT ["/ticktok.sh"]
  ```

  - docker build -t reg.navercorp.com/navertalk/ticktok .

  - docker login reg.navercorp.com

    ```bash
    vim ~/.docker/config.json (credsStore→credStore)
    ```

  - docker push ticktok reg.navercorp.com/navertalk/ticktok

### kubernetes 매니페스트 YAML 작성하기

- yaml 파일에 `imagePullPolicy`, `imagePullSecrets` 설정

  - kubernetes credential 설정

    ```bash
    kubectl create secret generic regcred \
        --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
        --type=kubernetes.io/dockerconfigjson
    ```

- pod / deployment / service (clusterIP) / service (NodePort)

- `ticktok-pod.yaml`

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: ticktok
    labels:
      name: ticktok
  spec:
    containers:
      - name: ticktok
        image: reg.navercorp.com/navertalk/ticktok
        imagePullPolicy: Always
        volumeMounts:
          - mountPath: /usr/share/nginx/html
            name: html
      - name: nginx
        image: nginx
        volumeMounts:
          - mountPath: /usr/share/nginx/html
            name: html
        ports:
          - containerPort: 80
    imagePullSecrets:
      - name: regcred
    volumes:
      - name: html
        emptyDir: {}
  ````

- `ticktock-deployment.yaml`

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ticktok
  spec:
    selector:
      matchLabels:
        app: ticktok
    template:
      metadata:
        labels:
          app: ticktok
      spec:
        containers:
          - name: ticktok
            image: reg.navercorp.com/navertalk/ticktok
            imagePullPolicy: Always
            volumeMounts:
              - mountPath: /usr/share/nginx/html
                name: html
          - name: nginx
            image: nginx
            volumeMounts:
              - mountPath: /usr/share/nginx/html
                name: html
            ports:
              - containerPort: 80
        imagePullSecrets:
          - name: regcred
        volumes:
          - name: html
            emptyDir: {}
  ```

- `ticktok-service.yaml` (ClusterIP)

  - `ClusterIP` 타입 서비스는 클러스터 내에서 도메인과 LoadBalancing 제공

  - 쿠버네티스에서 dns 를 제공하여 클러스터 내에서  `nslookup ticktok`  명령시 서비스 IP 를 제공함

  - 새로 시작된 파드에는 서비스의 도메인이 환경변수로 설정됨 `printenv | grep SERVICE`

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ticktok
    spec:
      selector:
        matchLabels:
          app: ticktok
      template:
        metadata:
          labels:
            app: ticktok
        spec:
          containers:
            - name: ticktok
              image: reg.navercorp.com/navertalk/ticktok
              imagePullPolicy: Always
              volumeMounts:
                - mountPath: /usr/share/nginx/html
                  name: html
            - name: nginx
              image: nginx
              volumeMounts:
                - mountPath: /usr/share/nginx/html
                  name: html
              ports:
                - containerPort: 80
          imagePullSecrets:
            - name: regcred
          volumes:
            - name: html
              emptyDir: {}
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: ticktok
    spec:
      selector:
        app: ticktok
      ports:
        - port: 80
          targetPort: 80
    ```

- `ticktok-service-nodeport.yaml` (NodePort)

- - `NodePort` 타입 서비스는 클러스터 외부에서 node IP 를 이용해서 접근할 수 있는 포트 제공

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ticktok
    spec:
      selector:
        matchLabels:
          app: ticktok
      template:
        metadata:
          labels:
            app: ticktok
        spec:
          containers:
            - name: ticktok
              image: reg.navercorp.com/navertalk/ticktok
              imagePullPolicy: Always
              volumeMounts:
                - mountPath: /usr/share/nginx/html
                  name: html
            - name: nginx
              image: nginx
              volumeMounts:
                - mountPath: /usr/share/nginx/html
                  name: html
              ports:
                - containerPort: 80
          imagePullSecrets:
            - name: regcred
          volumes:
            - name: html
              emptyDir: {}
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: ticktok
    spec:
      selector:
        app: ticktok
      type: NodePort
      ports:
        - port: 80
          targetPort: 80
    
    ```

    

### 헬스체크


  - readiness probe : 준비되면 트래픽 전달 시작

  - liveness probe : 죽었으면 재시작

  - 노드 장애시 kubelet 도 동작하지 않으므로 헬스체크로 대응할 수 없고, 컨트롤러가 사용됨 (deployment & statefulset)

  - yaml
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          volumeMounts:
            - mountPath: /usr/share/nginx/html
              name: html
          readinessProbe:
            httpGet:
              path: /ready
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /live
              port: 80
            initialDelaySeconds: 15
            periodSeconds: 6
          ports:
            - containerPort: 80
      volumes:
        - name: html
          emptyDir: {}
    ```

- initContainer

- Sidecar

### deployment

1. CLI 에서 deployment 실행방법

   - port 정보는 실제로 적용되지 않으며 informational 함

   ```bash
   kubectl create deployment nginx --image=nginx --port=8080 --replicas=3
   ```

2. manifest 를 사용하여 deployment 실행방법

   `nginx-deployment.yaml`

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: web-deploy
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: web-deploy
     template:
       metadata:
         labels:
           app: web-deploy
       spec:
         containers:
           - name: web-deploy
             image: nginx:latest
             resources:
               limits:
                 memory: "128Mi"
                 cpu: "500m"
             ports:
               - containerPort: 8080
   ```

   ```bash
   kubectl apply -f nginx-deployment.yaml
   ```

3. 접근하기

   - 클러스터 내부에서만 접속가능 (클러스터는 닫힌 네트워크, 모든 포트 접근 가능)
   - 클러스터 외부에서 접속하려면 service 를 사용해야 함

4. 왜 사용하나?

   - Pod 의 네크로맨서. 죽으면 다시 살려냄.
   - replicas / resource limits 의 변경에 따라 우아하게 scale in/out

     ```bash
     watch -n 0.1 "kubectl get pod"
     // replicas 변경
     // resource limits 변경
     // pod 삭제하기
     ```
     
### service

- 4개의 포트가 너무 헤깔림 (containerPort, targetPort, port, nodePort)
  - containerPort : 정보용
  - targetPort ~ port : 진짜 ~ 클러스터 내부용
  - nodePort : 클러스터 외부용 (범위 : 30000-32767)

- 클러스터 내부의 팟에서는 clusterIp, 환경변수, 도메인으로 서비스에 접근이 가능

  - clusterIP 확인 : `kubectl get service nginx`
  - 도메인 확인 : `nslookup nginx`
  - 환경변수 확인 : `printev | grep SERVICE` 

- 네가지 타입으로 접근성 제어  [publish services](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)

  - clusterIP : 클러스터 내부에서 접근 가능

  - nodePort : 클러스터 외부에서 접근 가능
    ```bash
    kubectl expose deployment nginx --type=NodePort --name=nginx
    kubectl describe service nginx // NodePort 확인
    curl {nodeIp}:{nodePort}
    ```

  - LoadBalancer : LoadBalancer 를 직접 설정할 수 있음

  - ExternalName : 도메인 연결?

  - Ingress 사용 가능

#### clusterIP 

```bash
# port=80 인 서비스 생성
kubectl expose deployment/nginx
```

- 서비스를 이용하면 cluster 내부에 Ip/환경변수/도메인으로 pod 를 노출한다.

  - ip
    ```bash
    # kubectl get service nginx 
    kubectl get service nginx
    ## 같은 클러스터의 pod 에서 nginx service 로드밸런싱 호출 가능 (클러스터 외부에서 호출 불가)
    kubectl run busybox --image=busybox --rm -it
    wget {cluster-ip}
    ```

  - 환경변수
    ```bash
    kubectl exec nginx-74d589986c-hfbs7 -- printenv | grep SERVICE
    NGINX_SERVICE_HOST=10.108.101.73
    NGINX_SERVICE_PORT=80
    ```

  - 도메인
    ```bash
    kubectl run curl --image=radial/busyboxplus:curl -i --tty
    nslookup nginx
    curl nginx
    ```

- 서비스를 인터넷에 노출시킬 때는 아래처럼 한다
  ```bash
  kubectl create deployment nginx --image=nginx --replicas=3 --port=80
  kubectl expose deployment nginx --type=NodePort --name=nginx
  ```
